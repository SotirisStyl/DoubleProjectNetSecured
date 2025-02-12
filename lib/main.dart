import 'package:cs_app2/quiz_main_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://wqmtemavpxxmanimglrz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxbXRlbWF2cHh4bWFuaW1nbHJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUxMzcxODgsImV4cCI6MjA1MDcxMzE4OH0.dnKQTpoJr4OYSzOn29ll3PfSdCyiEnpWRc_3i5dZGfA',
    debug: false,
  );
  Get.put(FluttermojiController());
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RedirectPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RedirectPage extends StatelessWidget {
  const RedirectPage({super.key});

  Future<bool> _isUserLoggedIn() async {
    final user = supabase.auth.currentUser;
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          // If the user is logged in, show the LeaderboardPage
          return const QuizMainPage();
        } else {
          // If the user is not logged in, show the HomePage
          return const HomePage();
        }
      },
    );
  }
}

