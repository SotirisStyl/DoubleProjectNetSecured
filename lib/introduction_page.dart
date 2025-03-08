import 'package:flutter/material.dart';
import 'quiz_page.dart';

class IntroductionPage extends StatelessWidget {
  final String topic;
  final String tableName;
  final String difficulty;

  IntroductionPage({
    super.key,
    required this.topic,
    required this.tableName,
    required this.difficulty,
  });

  final Map<String, List<TextSpan>> introductions = {
    'Safe Internet Usage': [
      const TextSpan(
        text:
        "In today’s digital world, using the internet safely is essential for protecting personal information, securing devices, and ensuring a positive online experience.\n\n",
      ),
      const TextSpan(
        text: "1. Creating and Managing Strong Passwords\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "   Use long, unique passwords and a password manager.\n\n",
      ),
      const TextSpan(
        text: "2. Recognizing Secure Websites and Connections\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "   Always check if the website is secured which is shown by the Hypertext Transfer Protocol Secure (HTTPS) and the padlock icon.\n\n",
      ),
      const TextSpan(
        text: "3. Safe Browsing Habits\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "   - Avoid clicking on suspicious links.\n"
            "   - Be cautious with downloads.\n"
            "   - Use pop-up blockers.\n\n",
      ),
      const TextSpan(
        text: "4. Protecting Personal Information\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "   Never share sensitive details on public platforms.\n\n",
      ),
      const TextSpan(
        text: "5. Using Public Wi-Fi and VPN\n",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: "   Always use a Virtual Private Network (VPN) when accessing public networks.\n",
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$topic Introduction'),
        backgroundColor: const Color(0xFF40C4FF),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      children: introductions[topic] ??
                          [const TextSpan(text: "Introduction not available.")],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          tableName: tableName,
                          difficulty: difficulty,
                        ),
                      ),
                    );
                  },
                  child: const Text("Start Quiz"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}