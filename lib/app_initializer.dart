import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'theme_provider.dart';
import 'home_page.dart';
import 'app_main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wqmtemavpxxmanimglrz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndxbXRlbWF2cHh4bWFuaW1nbHJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUxMzcxODgsImV4cCI6MjA1MDcxMzE4OH0.dnKQTpoJr4OYSzOn29ll3PfSdCyiEnpWRc_3i5dZGfA',
    debug: false,
  );

  Get.put(FluttermojiController());

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: themeProvider.backgroundColor,
          ),
          home: const RedirectPage(),
          debugShowCheckedModeBanner: false,
        );
      }
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
          return const QuizMainPage();
        } else {
          return const HomePage();
        }
      },
    );
  }
}
