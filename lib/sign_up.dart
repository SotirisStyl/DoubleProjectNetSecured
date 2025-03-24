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
  bool _obscurePassword = true;

  Future<void> signUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('All fields are required!');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters long.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Check if username already exists
      final usernameResponse = await Supabase.instance.client
          .from('users_data')
          .select()
          .eq('username', username);

      if (usernameResponse.isNotEmpty) {
        _showMessage('Username already exists. Please choose a different one.');
        return;
      }

      // Check if email already exists
      final emailResponse = await Supabase.instance.client
          .from('users_data')
          .select()
          .eq('email', email);

      if (emailResponse.isNotEmpty) {
        _showMessage('Email already exists. Please choose a different one.');
        return;
      }

      // Try to create user with Supabase Auth
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Only insert to users_data if sign-up succeeded
        await Supabase.instance.client.from('users_data').insert({
          'username': username,
          'email': email,
        });

        _showMessage('Sign up successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        _showMessage('Signup failed. Please try again.');
      }
    } catch (e) {
      _showMessage('An error occurred. Please try again.');
      print('SignUp Error: $e');
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
              const Padding(padding: EdgeInsets.only(top: 30)),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/AppImage.png',
                      fit: BoxFit.fitHeight,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.35,
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
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
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
            ],
          )),
    );
  }
}
