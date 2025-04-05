import 'package:flutter/material.dart';
import 'package:cs_app2/introduction_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the package for icons

import '../theme_provider.dart';

class BeginnerModePage extends StatefulWidget {
  final String difficulty;

  const BeginnerModePage({super.key, required this.difficulty});

  @override
  State<BeginnerModePage> createState() => _BeginnerModePageState();
}

class _BeginnerModePageState extends State<BeginnerModePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  Map<String, bool> quizProgress = {};
  bool isLoading = true;

  final Map<String, String> tableNames = {
    'Safe Internet Usage': 'safe_internet_usage_questions',
    'Cyber Hygiene': 'cyber_hygiene_questions',
    'Social Cyber Attacks': 'social_cyber_attacks_questions',
    'Basic Email Security': 'basic_email_security_questions',
    'Social Media Security': 'social_media_security_questions',
    'Recognizing Social Engineering': 'recognizing_social_engineering_questions',
    'General Data Protection Regulation': 'gdpr_questions',
    'Privacy, Safety, and Security Issues': 'privacy_safety_and_security_questions',
    'IoT and Ai in Cybersecurity': 'iot_and_ai_in_cybersecurity_questions',
  };

  final Map<String, IconData> categoryIcons = {
    'Cyber Hygiene': FontAwesomeIcons.shieldAlt,
    'Safe Internet Usage': FontAwesomeIcons.networkWired,
    'Social Cyber Attacks': FontAwesomeIcons.usersSlash,
    'Basic Email Security': FontAwesomeIcons.envelopeOpenText,
    'Social Media Security': FontAwesomeIcons.facebookF,
    'IoT and Ai in Cybersecurity': FontAwesomeIcons.robot,
    'Recognizing Social Engineering': FontAwesomeIcons.lock,
    'General Data Protection Regulation': FontAwesomeIcons.gavel,
    'Privacy, Safety, and Security Issues': FontAwesomeIcons.eyeSlash,
  };

  String? username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedUsername = prefs.getString('username');

    setState(() {
      username = storedUsername;
    });

    if (username != null) {
      fetchQuizProgress();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchQuizProgress() async {
    if (username == null) return;

    try {
      final response = await supabase
          .from('users_data')
          .select()
          .eq('username', username as Object)
          .single();

      final Map<String, dynamic> data = response;

      final Map<String, bool> progress = {};
      for (var entry in tableNames.entries) {
        String key = "${entry.value}_${widget.difficulty}".toLowerCase();
        progress[key] = data[key] == true;
      }

      setState(() {
        quizProgress = progress;
        isLoading = false;
      });
    } catch (error) {
      print("Error fetching progress: $error");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttonTitles = tableNames.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beginner Mode Quiz'),
        backgroundColor: context.watch<ThemeProvider>().selectedBackgroundColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Better than empty Scaffold
          : ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: tableNames.length + 1, // +1 for the image at the top
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Image.asset(
                  'assets/image1.png',
                  fit: BoxFit.cover,
                  width: 200,
                  height: 200,
                ),
              ),
            );
          }

          String title = tableNames.keys.elementAt(index - 1);
          String baseTable = tableNames[title]!;
          String tableKey = "${baseTable}_${widget.difficulty}".toLowerCase();
          bool isCompleted = quizProgress[tableKey] ?? false;

          return Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              tileColor: isCompleted
                  ? Colors.green
                  : const Color(0xff6200EE),
              textColor: Colors.white,
              leading: Icon(
                categoryIcons[title],
                size: 40.0,
                color: Colors.white,
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.white)
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntroductionPage(
                      topic: title,
                      tableName: baseTable,
                      difficulty: widget.difficulty,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

    );
  }
}
