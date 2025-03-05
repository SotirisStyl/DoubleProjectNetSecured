import 'package:flutter/material.dart';
import 'package:cs_app2/quiz_page.dart';

class IntermediateModePage extends StatelessWidget {
  final String difficulty; // Add difficulty parameter

  const IntermediateModePage({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> tableNames = {
      'Privacy': 'privacy_questions',
      'Cyber Hygiene': 'cyber_hygiene_questions',
      'Safe Internet Usage': 'safe_internet_usage_questions',
      'Social Cyber Attacks': 'social_cyber_attacks_questions',
      'Basic Email Security': 'basic_email_security_questions',
      'Social Media Security': 'social_media_security_questions',
      'Safety and Security Issues': 'safety_security_issues_questions',
      'Recognizing Social Engineering': 'recognizing_social_engineering_questions',
      'General Data Protection Regulation': 'gdpr_questions',
    };

    final List<String> buttonTitles = tableNames.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intermediate Mode Quiz'),
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Prevent scrolling
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttonTitles.map((title) {
                return Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: ElevatedButton(
                    onPressed: () {
                      String selectedTable = tableNames[title]!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(
                            tableName: selectedTable,
                            difficulty: difficulty,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6200EE),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(title),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
