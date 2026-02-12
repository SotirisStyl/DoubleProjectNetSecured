import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cs_app2/leaderboard.dart';
import 'package:cs_app2/profile_customization_page.dart';
import 'package:cs_app2/profile_page.dart';
import 'friends_page.dart';
import 'info_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:cs_app2/Quiz%20Modes/beginner_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/intermediate_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/advanced_mode_page.dart';
import 'package:cs_app2/fill_the_gaps_mode_page.dart';
import 'daily_trivia_page.dart';
import 'multiplayer_mode_page.dart';
import 'quiz_modes_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'quiz_page.dart';


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
      ProfilePage(onViewFriends: () {
        setState(() {
          _page = 4; // Index of FriendsPage
        });
      }),
      const FriendsPage(),
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
          Icon(Icons.people, size: 30, color: Colors.black),
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
  String? currentUsername;
  List<Map<String, dynamic>> pendingChallenges = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userPointsFuture = _fetchUserPoints();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    currentUsername = prefs.getString('username');

    if (currentUsername == null) return;

    try {
      final supabase = Supabase.instance.client;
      final username = currentUsername!; // Use non-null assertion
      final response = await supabase
          .from('multiplayer_challenges')
          .select()
          .eq('to_user', username)
          .eq('status', 'pending');

      setState(() {
        pendingChallenges = List<Map<String, dynamic>>.from(response);
      });

      // Poll every 3 seconds for new challenges
      while (mounted) {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) break;
        
        try {
          final updatedResponse = await supabase
              .from('multiplayer_challenges')
              .select()
              .eq('to_user', username)
              .eq('status', 'pending');

          setState(() {
            pendingChallenges = List<Map<String, dynamic>>.from(updatedResponse);
          });
        } catch (e) {
          print('Error polling challenges: $e');
        }
      }
    } catch (e) {
      print('Error loading challenges: $e');
    }
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

  Widget _buildMainModeButton(BuildContext context, String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      color: const Color(0xff6200EE),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        leading: FaIcon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: onTap,
      ),
    );
  }

  Future<void> _acceptChallenge(int challengeId, List<dynamic> questions, String fromUser) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('multiplayer_challenges')
          .update({'status': 'accepted'})
          .eq('id', challengeId);

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => QuizPage(
              tableName: 'multiplayer_questions',
              difficulty: 'multiplayer',
              preselectedQuestions: List<Map<String, dynamic>>.from(
                questions.map((q) => q as Map<String, dynamic>),
              ),
              challengeId: challengeId,
              opponentUsername: fromUser,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error accepting challenge: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectChallenge(int challengeId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('multiplayer_challenges')
          .update({'status': 'rejected'})
          .eq('id', challengeId);

      setState(() {
        pendingChallenges.removeWhere((c) => c['id'] == challengeId);
      });
    } catch (e) {
      print('Error rejecting challenge: $e');
    }
  }

  void _showChallengeNotification(Map<String, dynamic> challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Challenge Received!'),
        content: Text('${challenge['from_user']} is challenging you to a quiz!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectChallenge(challenge['id']);
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptChallenge(challenge['id'], challenge['questions'], challenge['from_user']);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // Show challenge notification if any pending challenges
    if (pendingChallenges.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && pendingChallenges.isNotEmpty) {
          final challenge = pendingChallenges[0];
          pendingChallenges.removeAt(0);
          _showChallengeNotification(challenge);
        }
      });
    }

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
            {
              'title': 'Fill the Gaps',
              'description': 'Test your knowledge by filling in the blanks.',
              'icon': FontAwesomeIcons.puzzlePiece,
              'color': const Color(0xff6200EE),
              'unlocked': true,
              'onTap': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FillTheGapsModePage(),
                  ),
                );
              },
            },
            {
              'title': 'Daily Trivia',
              'description': 'Answer daily questions for bonus points.',
              'icon': FontAwesomeIcons.calendarDay,
              'color': const Color(0xff6200EE),
              'unlocked': true,
              'onTap': () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyTriviaPage(),
                  ),
                );
              },
            },
          ];

          return Center(
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
                _buildMainModeButton(
                  context,
                  'Quizzes',
                  'Choose from different quiz modes.',
                  FontAwesomeIcons.questionCircle,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizModesPage(),
                      ),
                    );
                  },
                ),
                _buildMainModeButton(
                  context,
                  'Fill the Gaps',
                  'Test your knowledge by filling in the blanks.',
                  FontAwesomeIcons.puzzlePiece,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FillTheGapsModePage(),
                      ),
                    );
                  },
                ),
                _buildMainModeButton(
                  context,
                  'Multiplayer Mode',
                  'Challenge a friend with 10 random questions.',
                  FontAwesomeIcons.handshake,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MultiplayerModePage(),
                      ),
                    );
                  },
                ),
                _buildMainModeButton(
                  context,
                  'Daily Trivia',
                  'Answer daily questions for bonus points.',
                  FontAwesomeIcons.calendarDay,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DailyTriviaPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
