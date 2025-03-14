import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttermoji/fluttermoji.dart';

class ProfileCustomizationPage extends StatelessWidget {
  const ProfileCustomizationPage({super.key});

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
    } else {
      return Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Use a Row without Spacer
                const SizedBox(height: 20),
                // Display the current avatar in a circle
                FluttermojiCircleAvatar(
                  radius: 100, // sets the radius of the circle avatar
                ),
                const SizedBox(height: 10),  // Adding some space between the avatar and the customizer
                FluttermojiCustomizer(),
                const SizedBox(height: 10),  // Adding some space between the customizer and the save button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ],
            ),
          ),
      );
    }
  }
}


