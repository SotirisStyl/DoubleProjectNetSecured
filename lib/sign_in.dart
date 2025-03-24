import 'package:cs_app2/app_main_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true; // Controls password visibility

  Future<void> signIn(BuildContext context) async {
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = response.user;

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', user.id);

        final userResponse = await supabase
            .from('users_data')
            .select('username')
            .eq('email', user.email as Object)
            .single();

        if (context.mounted) {
          String username = userResponse['username'];
          await prefs.setString('username', username);

          _showMessage(context, 'Sign In successful!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => QuizMainPage()),
          );
        }
      } else {
        if (context.mounted) {
          _showMessage(context, 'Invalid email or password.');
        }
      }
    } on AuthException {
      if (context.mounted) {
        _showMessage(context, 'Invalid email or password.');
      }
    } catch (e) {
      if (context.mounted) {
        _showMessage(context, 'An error occurred. Please try again.');
        print(e);
      }
    }
  }

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
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, left: 35, right: 35),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      signIn(context);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
