import 'package:flutter/material.dart';
import 'package:cs_app2/introduction_page.dart';
import 'package:provider/provider.dart';

import '../theme_provider.dart';

class BeginnerModePage extends StatelessWidget {
  final String difficulty;

  const BeginnerModePage({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> tableNames = {
      'Cyber Hygiene': 'cyber_hygiene_questions',
      'Safe Internet Usage': 'safe_internet_usage_questions',
      'Social Cyber Attaches': 'social_cyber_attaches_questions',
      'Basic Email Security': 'basic_email_security_questions',
      'Social Media Security': 'social_media_security_questions',
      'IOT and Ai in Cybersecurity': 'iot_and_ai_in_cybersecurity_questions',
      'Recognizing Social Engineering': 'recognizing_social_engineering_questions',
      'General Data Protection Regulation': 'gdpr_questions',
      'Privacy, Safety and Security Issues': 'privacy_safety_and_security_questions',
    };

    final List<String> buttonTitles = tableNames.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beginner Mode Quiz'),
        backgroundColor: context.watch<ThemeProvider>().selectedBackgroundColor,
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
                  padding: const EdgeInsets.all(6.0),
                  child: ElevatedButton(
                    onPressed: () {
                      String selectedTable = tableNames[title]!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IntroductionPage(
                            topic: title,
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
