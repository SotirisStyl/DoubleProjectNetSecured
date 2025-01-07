import 'package:cs_app2/quiz_main_page.dart';
import 'package:flutter/material.dart';
import 'package:cs_app2/create_account.dart';
import 'package:cs_app2/login.dart';

//build main page for sign in and sign up and guest mode
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Padding(padding: const EdgeInsets.only(top: 30)),
            Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
              margin: const EdgeInsets.only(top: 15),
              child: const Text(
                'WELCOME!',
                style: TextStyle(fontSize: 30),
              ),
            ),
            Container(
              width: 150,
              height: 40,
              margin: const EdgeInsets.only(top: 20),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xff6200EE))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: const Text('Create Account',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              width: 150,
              height: 40,
              margin: const EdgeInsets.only(top: 20),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xff6200EE))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: const Text('Sign In', style: TextStyle(color: Colors.white)),
              ),
            ),
            Container(
              width: 150,
              height: 40,
              margin: const EdgeInsets.only(top: 20),
              child: TextButton(
                style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(const Color(0xff000000))),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizMainPage()),
                  );
                },
                child: const Text('Continue As Guest',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
                  ]),
                ),
          ],
        ));
  }
}
