import 'package:flutter/material.dart';
import 'package:cs_app2/Quiz%20Modes/beginner_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/intermediate_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/advanced_mode_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizModesPage extends StatefulWidget {
  const QuizModesPage({super.key});

  @override
  _QuizModesPageState createState() => _QuizModesPageState();
}

class _QuizModesPageState extends State<QuizModesPage> {
  late Future<int> _userPointsFuture;

  @override
  void initState() {
    super.initState();
    _userPointsFuture = _fetchUserPoints();
  }

  Future<int> _fetchUserPoints() async {
    final supabase = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    if (username.isEmpty) return 0;

    try {
      final response = await supabase
          .from('users_data')
          .select('user_points')
          .eq('username', username)
          .single();
      return response['user_points'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Modes'),
        backgroundColor: const Color(0xff6200EE),
      ),
      body: FutureBuilder<int>(
        future: _userPointsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          int userPoints = snapshot.data ?? 0;

          return Transform.translate(
            offset: const Offset(0, -50),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/image1.png',
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  _buildModeCard(
                    context,
                    'Beginner Mode',
                    'Start with the basics of cybersecurity.',
                    FontAwesomeIcons.seedling,
                    true,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BeginnerModePage(difficulty: 'beginner'),
                        ),
                      );
                    },
                  ),
                  _buildModeCard(
                    context,
                    'Intermediate Mode',
                    'Step up your knowledge and skills.',
                    FontAwesomeIcons.bookOpen,
                    userPoints >= 150,
                    userPoints >= 150
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IntermediateModePage(difficulty: 'intermediate'),
                        ),
                      );
                    }
                        : null,
                  ),
                  _buildModeCard(
                    context,
                    'Advanced Mode',
                    'Challenge yourself with advanced topics.',
                    FontAwesomeIcons.shieldHalved,
                    userPoints >= 400,
                    userPoints >= 400
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdvancedModePage(difficulty: 'advanced'),
                        ),
                      );
                    }
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModeCard(BuildContext context, String title, String description, IconData icon, bool isUnlocked, VoidCallback? onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: isUnlocked ? const Color(0xff6200EE) : Colors.grey.shade300,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        leading: FaIcon(
          icon,
          color: isUnlocked ? Colors.white : Colors.grey,
          size: 28,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.white : Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isUnlocked ? Colors.white70 : Colors.grey.shade500,
          ),
        ),
        trailing: isUnlocked
            ? const Icon(Icons.arrow_forward_ios, color: Colors.white)
            : const Icon(Icons.lock, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}