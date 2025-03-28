import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';
import 'package:cs_app2/app_main_page.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:avatar_glow/avatar_glow.dart';

class QuizPage extends StatefulWidget {
  final String tableName;
  final String difficulty;

  const QuizPage({super.key, required this.tableName, required this.difficulty});

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
    if (question['question_type'] == 'multiple choice') {
      List<String> answers = [
        question['answer_a'],
        question['answer_b'],
        question['answer_c'],
        question['answer_d'],
      ];
      answers.shuffle();
      return answers;
    } else {
      return ['Yes', 'No'];
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
                  question['question_text'],
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
