import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'home_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<String?> fetchUsername(String userId) async {
    final supabase = Supabase.instance.client;
    final response =
        await supabase.from('users_data').select('username').limit(1).single();

    if (response['username'] != null) {
      return response['username'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    // Check if the user is logged in
    if (currentUser == null) {
      // Handle guest users or logged-out state
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You are currently a guest.'),
              const Text('Please sign in to unlock this feature.'),
              Container(
                width: 150,
                height: 40,
                margin: const EdgeInsets.only(top: 20),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xff6200EE),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Handle logged-in users, fetch username asynchronously
      return FutureBuilder<String?>(
        future: fetchUsername(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while fetching data
            return const Scaffold(
              body: Center(
                child: Center(),
              ),
            );
          } else if (snapshot.hasError) {
            // Handle error case if fetching username fails
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Unable to load profile'),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            // If data is successfully fetched, display username
            final username = snapshot.data;

            return Scaffold(
              body: Center(
                child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 35, bottom: 25, right: 15, left: 15),
                        child: Row(
                          children: [
                            const Icon(
                                Icons.person,
                                size: 30, color: Colors.black),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                supabase.auth.signOut();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                );
                              },
                              child: const Icon(
                                Icons.logout,
                                size: 30,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FluttermojiCircleAvatar(),
                      Padding(padding: const EdgeInsets.only(top: 20)),
                      Text('Username: $username'),
                    ]),
              ),
            );
          } else {
            // Handle case where username is not found in the database
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Username not found'),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                      child: const Text('Back to Home'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      );
    }
  }
}
