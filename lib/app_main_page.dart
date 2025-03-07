import 'package:cs_app2/Quiz%20Modes/advanced_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/beginner_mode_page.dart';
import 'package:cs_app2/Quiz%20Modes/intermediate_mode_page.dart';
import 'package:flutter/material.dart';
import 'package:cs_app2/leaderboard.dart';
import 'package:cs_app2/profile_customization_page.dart';
import 'package:cs_app2/profile_page.dart';
import 'info_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class QuizMainPage extends StatefulWidget {
  const QuizMainPage({super.key});

  @override
  State<QuizMainPage> createState() => _QuizMainPageState();
}

class _QuizMainPageState extends State<QuizMainPage> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  // Pages for navigation
  final List<Widget> _pages = [
    const QuizHomePage(), // Home page widget
    ProfileCustomizationPage(), // Profile customization page
    LeaderboardPage(), // Leaderboard page
    ProfilePage(), // Profile page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Display the current page
          _pages[_page],

          if (_page == 0)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 35, left: 15.0),
                        child: const Icon(
                            Icons.home, size: 30, color: Colors.black),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(top: 35, right: 15.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => InfoPage()),
                            );
                          },
                          child: const Icon(
                            Icons.info_outline,
                            size: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  const Color(0xff6200EE)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BeginnerModePage(difficulty: 'beginner',)),
                              );
                            },
                            child: const Text('   Beginner Mode   ',
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  const Color(0xff6200EE)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => IntermediateModePage(difficulty: 'intermediate')),
                              );
                            },
                            child: const Text('Intermediate Mode',
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  const Color(0xff6200EE)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AdvancedModePage(difficulty: 'advanced')),
                              );
                            },
                            child: const Text('   Advanced Mode   ',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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
            _page = index; // Update the current page index
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
