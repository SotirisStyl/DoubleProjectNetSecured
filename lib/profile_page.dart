import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:fluttermoji/fluttermoji.dart';

// CustomPainter to draw the curved progress bar
class CurvedProgressBarPainter extends CustomPainter {
  final double progress; // Progress percentage
  final double startAngle; // Starting angle of the arc
  final double sweepAngle; // The sweep of the arc (in radians)
  final Color progressColor;

  CurvedProgressBarPainter({
    required this.progress,
    required this.startAngle,
    required this.sweepAngle,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    // Draw the background circle for the arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw the filled arc for the progress
    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Sweep the arc based on progress (convert the percentage to radians)
    double angle = (progress / 100) * sweepAngle;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2),
      startAngle,
      angle,
      false,
      progressPaint,
    );
  }

  bool shouldReclip(CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRepaint(CurvedProgressBarPainter oldDelegate) {
    return false;
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> userProgressFuture;

  @override
  void initState() {
    super.initState();
    userProgressFuture = fetchUserProgress();
  }

  // Function to fetch user progress and username from the database
  Future<Map<String, dynamic>> fetchUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) {
      return {}; // If username is not found, return an empty map.
    }

    // Fetch user progress from Supabase
    final response = await Supabase.instance.client
        .from('users_data')
        .select('username, safe_internet_usage_questions_beginner, safe_internet_usage_questions_intermediate, safe_internet_usage_questions_advanced')
        .eq('username', username)
        .single();

    return {
      "username": response['username'],
      "beginner": response['safe_internet_usage_questions_beginner'] ?? false,
      "intermediate": response['safe_internet_usage_questions_intermediate'] ?? false,
      "advanced": response['safe_internet_usage_questions_advanced'] ?? false,
    };
  }

  // Function to determine progress color dynamically
  Color getProgressColor(double progress) {
    if (progress < 50) {
      return Color.lerp(Colors.yellow, Colors.orange, progress / 50)!;
    } else if (progress < 100) {
      return Color.lerp(Colors.orange, Colors.green, (progress - 50) / 50)!;
    } else {
      return Colors.green; // Fully completed
    }
  }

  // Build the progress bar with curved design and color change based on percentage
  Widget buildProgressBar(double progress) {
    Color progressColor = getProgressColor(progress);

    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: const Text(
              'SFU',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(100, 100),
          painter: CurvedProgressBarPainter(
            progress: progress,
            startAngle: -3.14 / 2, // Start from the top
            sweepAngle: 6.28, // Full circular arc
            progressColor: progressColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: userProgressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          Map<String, dynamic> progress = snapshot.data ?? {};

          String username = progress["username"] ?? "Unknown";
          bool beginnerPassed = progress["beginner"] ?? false;
          bool intermediatePassed = progress["intermediate"] ?? false;
          bool advancedPassed = progress["advanced"] ?? false;

          // Calculate overall progress percentage
          double progressPercentage = 0;
          if (beginnerPassed) progressPercentage += 33.33;
          if (intermediatePassed) progressPercentage += 33.33;
          if (advancedPassed) progressPercentage += 33.34;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header
                Row(
                  children: [
                    const Icon(Icons.person, size: 30, color: Colors.black),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Supabase.instance.client.auth.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      child: const Icon(Icons.logout, size: 30, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                FluttermojiCircleAvatar(radius: 100),

                const SizedBox(height: 20),

                // Username
                Text(
                  'Username: $username',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),

                // Badge Section Title
                const Text("Badges", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 20),

                // Display Progress Bar with image in the center
                buildProgressBar(progressPercentage),
              ],
            ),
          );
        },
      ),
    );
  }
}
