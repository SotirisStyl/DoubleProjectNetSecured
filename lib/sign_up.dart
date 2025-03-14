import 'package:cs_app2/home_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signUp() async {
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showMessage('All fields are required!');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Step 1: Check if username already exists
      final usernameResponse = await Supabase.instance.client
          .from('users_data')
          .select()
          .eq('username', usernameController.text.trim());

      if (usernameResponse.isNotEmpty) {
        _showMessage(
            'Username already exists. Please choose a different username.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      final emailResponse = await Supabase.instance.client
          .from('users_data')
          .select()
          .eq('email', emailController.text.trim());

      if (emailResponse.isNotEmpty) {
        _showMessage('Email already exists. Please choose a different email.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      await Supabase.instance.client.from('users_data').insert({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim()
      });

      await Supabase.instance.client.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );

      _showMessage('Sign up successful!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      // Catch any unexpected errors
      _showMessage('An error occurred. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
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
              margin: const EdgeInsets.only(top: 5),
              child: const Text(
                'Sign Up!',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                    labelText: 'Username', prefixIcon: Icon(Icons.person)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                    labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: signUp,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}