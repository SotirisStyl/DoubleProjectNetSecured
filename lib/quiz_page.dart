import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';
import 'package:cs_app2/app_main_page.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'multiplayer_mode_page.dart';

class QuizPage extends StatefulWidget {
  final String tableName;
  final String difficulty;
  final List<Map<String, dynamic>>? preselectedQuestions;
  final int? challengeId;
  final String? opponentUsername;

  const QuizPage({
    super.key, 
    required this.tableName, 
    required this.difficulty, 
    this.preselectedQuestions,
    this.challengeId,
    this.opponentUsername,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> questions = [];
  List<String> shuffledAnswers = [];
  int currentIndex = 0;
  bool isLoading = true;
  int points = 0;
  final bool _animate = true;

  bool _isTimerEnabled = false;
  int _remainingTime = 300;
  Timer? _quizTimer;
  bool _timeExpired = false;

  String? selectedAnswer;
  bool hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _resetPoints();
    fetchQuestions();
    _loadTimerPreference();
  }

  @override
  void dispose() {
    _quizTimer?.cancel();
    _opponentScoreNotifier.dispose();
    super.dispose();
  }

  Future<void> _resetPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', 0);
    setState(() {
      points = 0;
    });
  }

  Future<void> fetchQuestions() async {
    try {
      if (widget.preselectedQuestions != null && widget.preselectedQuestions!.isNotEmpty) {
        setState(() {
          questions = List<Map<String, dynamic>>.from(widget.preselectedQuestions!);
          print('Preselected questions loaded. First question keys: ${questions[0].keys.toList()}');
          print('First question: ${questions[0]}');
          shuffledAnswers = _getShuffledAnswers(questions[0]);
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from(widget.tableName)
          .select()
          .eq('difficulty_level', widget.difficulty)
          .order('id', ascending: true);

      if (response.isEmpty) {
        print("No questions found!");
      }

      setState(() {
        questions = List<Map<String, dynamic>>.from(response);
        questions.shuffle(); // Randomize question order
        shuffledAnswers = _getShuffledAnswers(questions[0]); // Set initial shuffled answers
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching questions: $error");
    }
  }

  List<String> _getShuffledAnswers(Map<String, dynamic> question) {
    String qType = question['question_type']?.toString().toLowerCase() ?? 'multiple choice';
    
    if (qType.contains('yes/no') || qType == 'yes/no') {
      List<String> answers = ['Yes', 'No'];
      answers.shuffle();
      return answers;
    } else {
      List<String> answers = [
        question['answer_a']?.toString() ?? '',
        question['answer_b']?.toString() ?? '',
      ];
      // Only add answer_c and answer_d if they're not null
      if (question['answer_c'] != null) answers.add(question['answer_c'].toString());
      if (question['answer_d'] != null) answers.add(question['answer_d'].toString());
      
      answers.removeWhere((a) => a.isEmpty);
      answers.shuffle();
      return answers;
    }
  }

  Future<void> _updatePoints(int earnedPoints) async {
    final prefs = await SharedPreferences.getInstance();
    int currentPoints = prefs.getInt('points') ?? 0;
    int newPoints = currentPoints + earnedPoints;

    await prefs.setInt('points', newPoints);

    setState(() {
      points = newPoints;
    });
  }

  Future<void> _updateUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    int finalScore = prefs.getInt('points') ?? 0;

    if (username == null) {
      print("User not found");
      return;
    }

    try {
      final response = await supabase
          .from('users_data')
          .select('user_points')
          .eq('username', username)
          .single();

      int currentPoints = response['user_points'] ?? 0;
      int updatedPoints = currentPoints + finalScore;

      await supabase
          .from('users_data')
          .update({'user_points': updatedPoints})
          .eq('username', username);

      print("Updated user points: $updatedPoints for $username");
    } catch (error) {
      print("Error updating user points: $error");
    }
  }

  bool _checkAnswer() {
    if (_isTimerEnabled && _timeExpired) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Time is up!")));
      return false;
    }

    if (selectedAnswer == null) return false;

    Map<String, dynamic> question = questions[currentIndex];

    if (selectedAnswer == question['correct_answer']) {
      int questionPoints = question['points'] ?? 0;
      _updatePoints(questionPoints);
    }

    return true;
  }

  void _continueToNextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        hasSubmitted = false;
        shuffledAnswers = _getShuffledAnswers(questions[currentIndex]); // Reshuffle answers
      });
    } else {
      _quizTimer?.cancel();
      _showQuizCompletedDialog();
    }
  }

  void _showQuizCompletedDialog() async {
    final prefs = await SharedPreferences.getInstance();
    int finalScore = prefs.getInt('points') ?? 0;

    if (_isTimerEnabled && _timeExpired) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Time Expired"),
          content: const Text(
              "You did not complete the quiz within 5 minutes. No points were awarded."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => QuizMainPage()),
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (widget.difficulty == "beginner" && finalScore >= 35) {
      await _updateQuizProgress(widget.tableName, widget.difficulty);
    } else if (widget.difficulty == "intermediate" && finalScore >= 70) {
      await _updateQuizProgress(widget.tableName, widget.difficulty);
    } else if (widget.difficulty == "advanced" && finalScore >= 140) {
      await _updateQuizProgress(widget.tableName, widget.difficulty);
    }

    await _updateUserPoints();

    // Handle multiplayer results
    if (widget.challengeId != null) {
      await _saveMultiplayerScore(finalScore);
      _showMultiplayerResults(finalScore);
    } else {
      // Regular quiz completion
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Quiz Completed"),
          content: Text("You scored $finalScore points!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => QuizMainPage()),
                );
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveMultiplayerScore(int score) async {
    if (widget.challengeId == null) return;
    
    try {
      final username = (await SharedPreferences.getInstance()).getString('username');
      if (username == null) return;

      // Fetch current player_scores
      final challengeData = await supabase
          .from('multiplayer_challenges')
          .select('player_scores')
          .eq('id', widget.challengeId!)
          .single();

      final playerScores = Map<String, dynamic>.from(challengeData['player_scores'] as Map<String, dynamic>? ?? {});
      playerScores[username] = score;

      // Update with the new scores
      await supabase
          .from('multiplayer_challenges')
          .update({'player_scores': playerScores})
          .eq('id', widget.challengeId!);
      
      print('Saved score $score for $username in challenge ${widget.challengeId}');
    } catch (e) {
      print('Error saving multiplayer score: $e');
    }
  }

  void _showMultiplayerResults(int yourScore) async {
    if (widget.challengeId == null) return;
    
    int? opponentScore;

    if (!mounted) return;

    // Log context for debugging
    print('Showing multiplayer results: challengeId=${widget.challengeId}, opponent=${widget.opponentUsername}, yourScore=$yourScore');

    // Start polling once and show dialog immediately
    _startPolling();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Results"),
        content: ValueListenableBuilder<int?>(
          valueListenable: _opponentScoreNotifier,
          builder: (context, opponentScore, child) {
            final live = opponentScore;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your Score: $yourScore', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('${widget.opponentUsername}\'s Score: ${live ?? "..."}', 
                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                const SizedBox(height: 16),
                if (live != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: yourScore > live ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      yourScore > live ? 'You Won! 🎉' : yourScore == live ? 'It\'s a Tie!' : 'You Lost',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ] else ...[
                  const SizedBox(
                    height: 30,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MultiplayerModePage()),
              );
            },
            child: const Text("Rematch"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => QuizMainPage()),
              );
            },
            child: const Text("Back to Home"),
          ),
        ],
      ),
    );
  }

  final ValueNotifier<int?> _opponentScoreNotifier = ValueNotifier(null);
  bool _isPolling = false;

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    // run polling in background
    _pollOpponentScore();
  }

  Future<void> _pollOpponentScore() async {
    try {
      int pollCount = 0;
      const int maxPolls = 30; // Poll for up to 60 seconds

      while (_opponentScoreNotifier.value == null && pollCount < maxPolls && mounted) {
        await Future.delayed(const Duration(seconds: 2));
        pollCount++;

        try {
          final challengeData = await supabase
              .from('multiplayer_challenges')
              .select('player_scores')
              .eq('id', widget.challengeId!)
              .single();

          final raw = challengeData['player_scores'];
          // Log raw value and types for debugging
          print('Fetched player_scores raw: $raw (type: ${raw.runtimeType})');
          final playerScores = (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
          print('Parsed player_scores keys: ${playerScores.keys.toList()} (opponentUsername=${widget.opponentUsername})');

          if (widget.opponentUsername != null && playerScores.containsKey(widget.opponentUsername)) {
            final scoreVal = playerScores[widget.opponentUsername];
            print('Found value for opponent: $scoreVal (type: ${scoreVal.runtimeType})');
            final score = (scoreVal is int) ? scoreVal : (scoreVal is num ? scoreVal.toInt() : null);
            if (score != null) {
              _opponentScoreNotifier.value = score;
              print('Opponent score found: $score');
              break;
            }
          }
        } catch (e) {
          print('Error polling for opponent score: $e');
        }
      }

      if (_opponentScoreNotifier.value == null && pollCount >= maxPolls) {
        _opponentScoreNotifier.value = 0; // Mark as timeout
      }
    } catch (e) {
      print('Error in polling: $e');
    }
  }

  Future<void> _updateQuizProgress(String category, String difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      print("User not found");
      return;
    }

    String columnName = "${category}_${difficulty}".toLowerCase();

    try {
      await supabase
          .from('users_data')
          .update({columnName: true})
          .eq('username', username);

      print("Updated $columnName to TRUE for $username");
    } catch (error) {
      print("Error updating quiz progress: $error");
    }
  }

  Future<void> _loadTimerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool timerEnabled = prefs.getBool('quiz_timer_enabled') ?? false;
    setState(() {
      _isTimerEnabled = timerEnabled;
    });
    if (timerEnabled) {
      _startTimer();
    }
  }

  void _startTimer() {
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _timeExpired = true;
        });
        _quizTimer?.cancel();
        _quizTimer = null;
        _showTimeExpiredDialog();
      }
    });
  }

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Time Expired"),
        content: const Text(
            "You did not complete the quiz within 5 minutes. No points were awarded."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => QuizMainPage()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String formatDuration(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isNotEmpty) {
      Map<String, dynamic> question = questions[currentIndex];

      return Scaffold(
        backgroundColor: context.watch<ThemeProvider>().selectedBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: _isTimerEnabled
                            ? Text(
                          "Time Remaining: ${formatDuration(_remainingTime)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                            : const SizedBox(),
                      ),
                    ),
                    Text(
                      "${currentIndex + 1}/${questions.length}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                AvatarGlow(
                  startDelay: const Duration(milliseconds: 1000),
                  glowColor: Colors.white,
                  glowShape: BoxShape.circle,
                  animate: _animate,
                  curve: Curves.fastOutSlowIn,
                  child: Material(
                    elevation: 1.0,
                    shape: const CircleBorder(),
                    color: Colors.transparent,
                    child: FluttermojiCircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  question['questions_text'] ?? question['question_text'] ?? 'Question',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                ...shuffledAnswers.map((answer) => buildAnswerButton(answer)).toList(),

                if (!hasSubmitted)
                  ElevatedButton(
                    onPressed: selectedAnswer == null
                        ? null
                        : () {
                      _checkAnswer();
                      setState(() {
                        hasSubmitted = true;
                      });
                    },
                    child: const Text("Submit"),
                  )
                else
                  ElevatedButton(
                    onPressed: _continueToNextQuestion,
                    child: const Text("Continue"),
                  ),

                Text(
                  "Points: $points",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }

  bool isCorrectAnswer(String answer) {
    return answer == questions[currentIndex]['correct_answer'];
  }

  Widget buildAnswerButton(String answer) {
    final bool isSelected = selectedAnswer == answer;
    final bool isCorrect = isCorrectAnswer(answer);

    Color? borderColor;
    Icon? icon;

    if (hasSubmitted) {
      if (isCorrect) {
        borderColor = Colors.green;
        icon = const Icon(Icons.check, color: Colors.green);
      } else if (isSelected && !isCorrect) {
        borderColor = Colors.red;
        icon = const Icon(Icons.close, color: Colors.red);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          side: hasSubmitted
              ? BorderSide(color: borderColor ?? Colors.transparent, width: 2)
              : BorderSide.none,
          backgroundColor:
          isSelected && !hasSubmitted ? Colors.blueAccent : null,
          foregroundColor: Colors.black,
        ),
        onPressed: hasSubmitted
            ? null
            : () {
          setState(() {
            selectedAnswer = answer;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: Text(answer)),
            if (hasSubmitted && (isSelected || isCorrect))
              icon ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
