import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cs_app2/info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late Future<List<Map<String, dynamic>>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = _fetchLeaderboard(); // Fetch data on init
  }

  Future<List<Map<String, dynamic>>> _fetchLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    // If user is not logged in, return empty list
    if (username == null || username.isEmpty) {
      return [];
    }

    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('users_data')
        .select('username, user_points')
        .order('user_points', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  void _refreshLeaderboard() {
    setState(() {
      _leaderboardFuture = _fetchLeaderboard(); // Refresh data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 35, left: 15.0, right: 15.0, bottom: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.leaderboard, size: 25, color: Colors.black),
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
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _leaderboardFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // If no data (guest user scenario)
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline, size: 80, color: Colors.black),
                            const SizedBox(height: 20),
                            const Text(
                              "You are currently a guest.",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Please sign in to unlock this feature.",
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final leaderboard = snapshot.data!;

                  return ListView.builder(
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final user = leaderboard[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${index + 1}. ${user['username']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${user['user_points']} pts',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
