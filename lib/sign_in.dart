import 'package:cs_app2/quiz_main_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';

class LoginPage extends StatelessWidget {
  // Controllers for user input
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  // Function to sign in
  Future<void> signIn(BuildContext context) async {
    try {
      // Perform sign-in using Supabase
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if the widget is still mounted before showing a message
      if (context.mounted) {
        _showMessage(context, 'Sign In successful!');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => QuizMainPage()));
      }
    } on AuthException {
      // Handle authentication error
      if (context.mounted) {
        _showMessage(context, 'Invalid email or password.');
      }
    } catch (e) {
      // Handle error and ensure context is still valid before showing message
      if (context.mounted) {
        _showMessage(context, 'An error occurred. Please try again.');
      }
    }
  }

  // Show messages using SnackBar
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: const EdgeInsets.only(top: 30)),
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
                  Container(
                    margin: const EdgeInsets.only(top: 25),
                    child: const Text(
                      'Sign In!',
                      style: TextStyle(fontSize: 30),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
                    child: TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
                    child: TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Use a simple ElevatedButton for login
                  ElevatedButton(
                    onPressed: () {
                      // Call the signIn method
                      signIn(context);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
}
