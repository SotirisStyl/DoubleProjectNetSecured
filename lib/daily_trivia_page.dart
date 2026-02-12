import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';
import 'package:cs_app2/app_main_page.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:avatar_glow/avatar_glow.dart';

class DailyTriviaPage extends StatefulWidget {
  const DailyTriviaPage({super.key});

  @override
  _DailyTriviaPageState createState() => _DailyTriviaPageState();
}

class _DailyTriviaPageState extends State<DailyTriviaPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> questions = [];
  List<String> shuffledAnswers = [];
  int currentIndex = 0;
  bool isLoading = true;
  int points = 0;
  bool alreadyPlayedToday = false;
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
    _checkIfPlayedToday();
  }

  @override
  void dispose() {
    _quizTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkIfPlayedToday() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10);
    String? lastPlayed = prefs.getString('last_daily_trivia_date');
    if (lastPlayed == today) {
      setState(() {
        alreadyPlayedToday = true;
        isLoading = false;
      });
    } else {
      _resetPoints();
      fetchQuestions();
    }
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
          .from('daily_trivia_questions')
          .select('id, question_text, answer_a, answer_b, answer_c, answer_d, correct_answer, question_type, points');

      if (response.isEmpty) {
        print("No questions found!");
      }

      List<Map<String, dynamic>> allQuestions = List<Map<String, dynamic>>.from(response);
      // Sort by id to ensure consistent order
      allQuestions.sort((a, b) => a['id'].compareTo(b['id']));

      // Select question based on day of year for consistency
      DateTime now = DateTime.now();
      int dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      int index = dayOfYear % allQuestions.length;
      List<Map<String, dynamic>> selectedQuestions = [allQuestions[index]];

      setState(() {
        questions = selectedQuestions;
        shuffledAnswers = _getShuffledAnswers();
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching questions: $error");
    }
  }

  List<String> _getShuffledAnswers() {
    Map<String, dynamic> question = questions[0];
    if (question['question_type'] == 'multiple_choice') {
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
      int updatedPoints = currentPoints + 50; // Fixed 50 points for daily trivia

      await supabase
          .from('users_data')
          .update({'user_points': updatedPoints})
          .eq('username', username);

      // Mark as played today
      String today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('last_daily_trivia_date', today);

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
        shuffledAnswers = _getShuffledAnswers();
      });
    } else {
      _quizTimer?.cancel();
      _showQuizCompletedDialog();
    }
  }

  void _showQuizCompletedDialog() async {
    await _updateUserPoints();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Daily Trivia Completed"),
        content: const Text("You have completed the daily trivia! You earned 50 points."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const QuizMainPage()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (alreadyPlayedToday) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          title: const Text("Daily Trivia"),
          backgroundColor: const Color(0xff6200EE),
        ),
        body: const Center(
          child: Text("You have already played the daily trivia today. Come back tomorrow!"),
        ),
      );
    }

    if (isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: const Center(child: Text("No questions available")),
      );
    }

    Map<String, dynamic> currentQuestion = questions[currentIndex];

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text("Daily Trivia"),
        backgroundColor: const Color(0xff6200EE),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
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
            Text(
              "Question ${currentIndex + 1} of ${questions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              currentQuestion['question_text'],
              style: const TextStyle(fontSize: 20),
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
            Text("Points: $points", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}