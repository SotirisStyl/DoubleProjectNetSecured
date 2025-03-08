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
    _leaderboardFuture = _fetchLeaderboard(); // Fetch leaderboard once
    _userPointsFuture = _fetchUserPoints(); // Fetch user's points once
  }

  // Fetch the leaderboard data from Supabase
  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('users_data')
        .select('username, user_points')
        .order('user_points', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch the user's points from Supabase based on their username
  Future<int> _fetchUserPoints() async {
    final supabase = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final response = await supabase
        .from('users_data')
        .select('user_points')
        .eq('username', username)
        .single();

    if (response != null) {
      return response['user_points'] ?? 0;  // Return the user's points or 0 if no data
    } else {
      return 0;  // Return 0 if no data found
    }
  }

  // Refresh leaderboard data
  void _refreshLeaderboard() {
    setState(() {
      _leaderboardFuture = _fetchLeaderboard(); // Refresh data
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const QuizHomePage(),
      ProfileCustomizationPage(),
      LeaderboardPage(),
      ProfilePage(),
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
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
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
    _userPointsFuture = _fetchUserPoints(); // Refresh points every time user enters
  }

  Future<int> _fetchUserPoints() async {
    final supabase = Supabase.instance.client;
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final response = await supabase
        .from('users_data')
        .select('user_points')
        .eq('username', username)
        .single();

    return response != null ? response['user_points'] ?? 0 : 0;
  }

  Widget _buildModeButton(String text, Color color, bool isUnlocked, VoidCallback? onPressed) {
    return Stack(
      alignment: Alignment.center,
      children: [
        TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(isUnlocked ? color : Colors.black),
          ),
          onPressed: onPressed,
          child: Text(text, style: TextStyle(color: Colors.white)),
        ),
        if (!isUnlocked)
          Positioned(
            child: Icon(Icons.lock, color: Colors.white.withAlpha(178), size: 20),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 35, left: 15.0),
                    child: Icon(Icons.home, size: 30, color: Colors.black),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 35, right: 15.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InfoPage()),
                        );
                      },
                      child: const Icon(Icons.info_outline, size: 30, color: Colors.black),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildModeButton(
                        'Beginner Mode',
                        const Color(0xff6200EE),
                        true,
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => BeginnerModePage(difficulty: 'beginner')),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<int>(
                        future: _userPointsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return const Text('Error fetching user points');
                          }

                          int userPoints = snapshot.data ?? 0;
                          bool isUnlocked = userPoints >= 100;

                          return _buildModeButton(
                            'Intermediate Mode',
                            const Color(0xff6200EE),
                            isUnlocked,
                            isUnlocked
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => IntermediateModePage(difficulty: 'intermediate')),
                              );
                            }
                                : null,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<int>(
                        future: _userPointsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return const Text('Error fetching user points');
                          }

                          int userPoints = snapshot.data ?? 0;
                          bool isUnlocked = userPoints >= 200;

                          return _buildModeButton(
                            'Advanced Mode',
                            const Color(0xff6200EE),
                            isUnlocked,
                            isUnlocked
                                ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdvancedModePage(difficulty: 'advanced')),
                              );
                            }
                                : null,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
