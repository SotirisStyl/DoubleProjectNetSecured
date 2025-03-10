import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:cs_app2/info_page.dart';

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
        body: SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
          child: Center(
            child: Column(
              children: [
                // Use a Row without Spacer
                Padding(
                  padding: const EdgeInsets.only(top: 35, left: 15, right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensure proper spacing
                    children: [
                      const Icon(Icons.palette, size: 30, color: Colors.black),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InfoPage()),
                          );
                        },
                        child: const Icon(Icons.info_outline, size: 30, color: Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
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
                  child: SizedBox(
                    width: 100,  // Set the desired width of the button
                    child: InkWell(
                      onTap: () {
                        // Your onPressed functionality
                        FluttermojiSaveWidget();
                      },
                      splashColor: Colors.white,  // Optional: splash color on tap
                      borderRadius: BorderRadius.circular(10.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),  // Add padding to give the button some height
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,  // Centering the icon and text inside the Row
                          children: [
                            Icon(
                              Icons.save, // You can change this to any icon
                              color: Colors.white, // Change the icon color here
                            ),
                            const SizedBox(width: 10),  // Adding space between the save button and text
                            const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}


