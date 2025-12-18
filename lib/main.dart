import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme_provider.dart';
import 'home_page.dart';
import 'app_main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
