import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_provider.dart';
import 'package:cs_app2/app_main_page.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:avatar_glow/avatar_glow.dart';

class FillTheGapsPage extends StatefulWidget {
  final String tableName;
  final String difficulty;

  const FillTheGapsPage({super.key, required this.tableName, required this.difficulty});

  @override
  _FillTheGapsPageState createState() => _FillTheGapsPageState();
}

class _FillTheGapsPageState extends State<FillTheGapsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> questions = [];
  List<String> shuffledAnswers = [];
  int currentIndex = 0;
  bool isLoading = true;
  int points = 0;
  final bool _animate = true;

  String? selectedAnswer;
  bool hasSubmitted = false;
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    _resetPoints();
    fetchQuestions();
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
          .select('id, questions_text, answer, points');

      if (response.isEmpty) {
        print("No questions found!");
      }

      List<Map<String, dynamic>> allQuestions = List<Map<String, dynamic>>.from(response);
      allQuestions.shuffle();
      List<Map<String, dynamic>> selectedQuestions = allQuestions.take(10).toList();

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
    List<String> answers = questions.map((q) => q['answer'] as String).toList();
    answers.shuffle();
    return answers;
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

  void _onAnswerSelected(String answer) {
    setState(() {
      selectedAnswer = answer;
      hasSubmitted = true;
      attempts++;
    });

    Map<String, dynamic> question = questions[currentIndex];
    String correctAnswer = question['answer'];

    if (answer == correctAnswer) {
      int questionPoints = question['points'] ?? 0;
      _updatePoints(questionPoints);
      _continueToNextQuestion();
    } else {
      // Wrong answer, deduct points based on difficulty
      int penalty = 0;
      if (widget.difficulty == 'easy') penalty = -2;
      else if (widget.difficulty == 'medium') penalty = -4;
      else if (widget.difficulty == 'hard') penalty = -8;
      _updatePoints(penalty);
      // Stay on the same question, allow retry
      setState(() {
        hasSubmitted = false;
        selectedAnswer = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Wrong answer! Try again. Penalty: $penalty points")),
      );
    }
  }

  void _continueToNextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        hasSubmitted = false;
        attempts = 0;
        shuffledAnswers = _getShuffledAnswers(); // Reshuffle for new question
      });
    } else {
      _showQuizCompletedDialog();
    }
  }

  void _showQuizCompletedDialog() async {
    final prefs = await SharedPreferences.getInstance();
    int finalScore = prefs.getInt('points') ?? 0;

    await _updateUserPoints();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Completed"),
        content: Text("You have completed the quiz! Your score: $finalScore points"),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

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
                  const SizedBox(), // Spacer for center
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
                currentQuestion['questions_text'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.25,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 10,
                ),
                itemCount: shuffledAnswers.length,
                itemBuilder: (context, index) {
                  String answer = shuffledAnswers[index];
                  return buildAnswerButton(answer);
                },
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
  }

  Widget buildAnswerButton(String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: hasSubmitted ? null : () => _onAnswerSelected(answer),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
          backgroundColor: selectedAnswer == answer ? Colors.blue : Colors.white,
          foregroundColor: Colors.black,
        ),
        child: Text(answer),
      ),
    );
  }
}