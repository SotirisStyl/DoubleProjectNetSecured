import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int currentIndex = 0;
  bool isLoading = true;
  int points = 0; // Local points counter

  @override
  void initState() {
    super.initState();
    _resetPoints(); // Reset points at the start of the quiz
    fetchQuestions();
  }

  Future<void> _resetPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', 0); // Reset local stored points
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
          .order('id', ascending: true); // Ensure ordered questions

      setState(() {
        questions = response;
        isLoading = false;
      });

      if (questions.isEmpty) {
        print("No questions found!");
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching questions: $error");
    }
  }

  Future<void> _updatePoints(int earnedPoints) async {
    final prefs = await SharedPreferences.getInstance();
    int currentPoints = prefs.getInt('points') ?? 0;
    int newPoints = currentPoints + earnedPoints;

    await prefs.setInt('points', newPoints);

    setState(() {
      points = newPoints; // Update UI with new points
    });
  }

  Future<void> _updateUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    int finalScore = prefs.getInt('points') ?? 0; // Get final quiz score

    if (username == null) {
      print("User not found");
      return;
    }

    try {
      // Fetch existing points from Supabase
      final response = await supabase
          .from('users_data')
          .select('user_points')
          .eq('username', username)
          .single();

      int currentPoints = response['user_points'] ?? 0;
      int updatedPoints = currentPoints + finalScore;

      // Update total points in Supabase
      await supabase
          .from('users_data')
          .update({'user_points': updatedPoints})
          .eq('username', username);

      print("Updated user points: $updatedPoints for $username");
    } catch (error) {
      print("Error updating user points: $error");
    }
  }

  void _checkAnswer(String selectedAnswer) {
    Map<String, dynamic> question = questions[currentIndex];

    if (selectedAnswer == question['correct_answer']) {
      int questionPoints = question['points'] ?? 0;
      _updatePoints(questionPoints); // Update local points
    }

    // Move to next question or finish quiz
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _showQuizCompletedDialog();
    }
  }

  void _showQuizCompletedDialog() async {
    final prefs = await SharedPreferences.getInstance();
    int finalScore = prefs.getInt('points') ?? 0;

    // Check if quiz progress should be updated
    if (widget.difficulty == "beginner" && finalScore >= 35) {
      await _updateQuizProgress(widget.tableName, widget.difficulty);
    } else if (widget.difficulty == "intermediate" && finalScore >= 70) {
      await _updateQuizProgress(widget.tableName, widget.difficulty);
    } else if (widget.difficulty == "advanced" && finalScore >= 140) {
      await _updateQuizProgress(widget.tableName, widget.difficulty);
    }

    // Update user points in Supabase after quiz completion
    await _updateUserPoints();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quiz Completed"),
        content: Text("You scored $finalScore points!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Exit quiz page
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions available')),
      );
    }

    Map<String, dynamic> question = questions[currentIndex];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                question['question_text'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              if (question['question_type'] == 'multiple choice') ...[
                buildAnswerButton(question['answer_a']),
                buildAnswerButton(question['answer_b']),
                buildAnswerButton(question['answer_c']),
                buildAnswerButton(question['answer_d']),
              ] else ...[
                buildAnswerButton('Yes'),
                buildAnswerButton('No'),
              ],

              const SizedBox(height: 20),
              Text("Points: $points", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        onPressed: () => _checkAnswer(answer),
        child: Text(answer),
      ),
    );
  }
}
