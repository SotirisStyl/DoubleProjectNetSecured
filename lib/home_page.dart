import 'package:cs_app2/app_main_page.dart';
import 'package:flutter/material.dart';
import 'package:cs_app2/sign_up.dart';
import 'package:cs_app2/sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Main Home Page for sign in / sign up / guest
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://wqmtemavpxxmanimglrz.supabase.co/auth/v1/callback',
      );

      // The user will be redirected externally, so this part won’t be called immediately.
    } catch (e) {
      print('Google Sign-In Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign in with Google')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // To handle overflow on smaller screens
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/AppImage.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.38,
                  ),
                  Image.asset(
                    'assets/Lines.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.14,
                  ),
                  const Text(
                    'WELCOME!',
                    style: TextStyle(fontSize: 30),
                  ),
                  buildButton(context, 'Create Account', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  }),
                  buildButton(context, 'Sign In', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }),
                  buildButton(context, 'Continue As Guest', () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Guest Account'),
                          content: const Text(
                              'You are currently using a guest account. Features will be limited.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const QuizMainPage()),
                                );
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "---------------- OR CONTINUE WITH ----------------",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.google, size: 35),
                    onPressed: () => signInWithGoogle(context),
                    splashRadius: 25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      width: 180,
      height: 45,
      margin: const EdgeInsets.only(top: 10),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(const Color(0xff6200EE)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
