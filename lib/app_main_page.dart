import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cs_app2/leaderboard.dart';
import 'package:cs_app2/profile_customization_page.dart';
import 'package:cs_app2/profile_page.dart';
import 'info_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cs_app2/Quiz%20Modes/beginner_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/intermediate_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/advanced_mode_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class _QuizMainPageState extends State<QuizMainPage> {
  int _page = 0;
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;
  late Future<int> _userPointsFuture;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _fetchLeaderboard();
    _userPointsFuture = _fetchUserPoints();
  }

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('users_data')
        .select('username, user_points')
        .order('user_points', ascending: false);

    return List<Map<String, dynamic>>.from(response);
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

  void _refreshLeaderboard() {
    setState(() {
      _leaderboardFuture = _fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const QuizHomePage(),
      ProfileCustomizationPage(),
      LeaderboardPage(),
      ProfilePage(),
      InfoPage(),
    ];

    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _page,
        height: 50.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.palette, size: 30, color: Colors.black),
          Icon(Icons.leaderboard, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
          Icon(Icons.info, size: 30, color: Colors.black),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Color(0xff6200EE),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  _QuizHomePageState createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  late Future<int> _userPointsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      setState(() {});
      return response['user_points'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Widget _buildModeButton(String text, Color color, bool isUnlocked,
      VoidCallback? onPressed) {
    return SizedBox(
      width: 200, // Adjust the width as needed
      height: 55, // Adjust the height as needed
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
              isUnlocked ? color : Colors.black),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Padding(
                padding: const EdgeInsets.only(right: 9.0),
                child: Icon(
                    Icons.lock, color: Colors.white.withAlpha(178), size: 20),
              ),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<int>(
        future: _userPointsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold();
          }

          int userPoints = snapshot.data ?? 0;

          final List<Map<String, dynamic>> quizModes = [
            {
              'title': 'Beginner Mode',
              'description': 'Start with the basics of cybersecurity.',
              'icon': FontAwesomeIcons.seedling,
              'color': const Color(0xff6200EE),
              'unlocked': true,
              'onTap': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const BeginnerModePage(difficulty: 'beginner'),
                  ),
                );
              },
            },
            {
              'title': 'Intermediate Mode',
              'description': 'Step up your knowledge and skills.',
              'icon': FontAwesomeIcons.bookOpen,
              'color': const Color(0xff6200EE),
              'unlocked': userPoints >= 150,
              'onTap': userPoints >= 150
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IntermediateModePage(
                        difficulty: 'intermediate'),
                  ),
                );
              }
                  : null,
            },
            {
              'title': 'Advanced Mode',
              'description': 'Challenge yourself with advanced topics.',
              'icon': FontAwesomeIcons.shieldHalved,
              'color': const Color(0xff6200EE),
              'unlocked': userPoints >= 400,
              'onTap': userPoints >= 400
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const AdvancedModePage(difficulty: 'advanced'),
                  ),
                );
              }
                  : null,
            },
          ];

          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image1.png',
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                        for (var mode in quizModes)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            color: mode['unlocked']
                                ? const Color(0xff6200EE)  // Purple color for unlocked
                                : Colors.grey.shade300, // Grey color for locked
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                              leading: FaIcon(
                                mode['icon'],
                                color: mode['unlocked'] ? Colors.white : Colors.grey, // White for unlocked, grey for locked
                                size: 28,
                              ),
                              title: Text(
                                mode['title'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: mode['unlocked'] ? Colors.white : Colors.grey.shade600, // White for unlocked, grey for locked
                                ),
                              ),
                              subtitle: Text(
                                mode['description'],
                                style: TextStyle(
                                  color: mode['unlocked'] ? Colors.white70 : Colors.grey.shade500, // Light white for unlocked, grey for locked
                                ),
                              ),
                              trailing: mode['unlocked']
                                  ? const Icon(Icons.arrow_forward_ios, color: Colors.white) // Arrow for unlocked
                                  : const Icon(Icons.lock, color: Colors.grey), // Lock for locked
                              onTap: mode['unlocked'] ? mode['onTap'] : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
