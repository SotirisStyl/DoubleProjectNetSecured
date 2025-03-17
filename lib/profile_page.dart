import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'package:fluttermoji/fluttermoji.dart';

import 'theme_provider.dart';

import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;


// CustomPainter for the curved progress bar
class CurvedProgressBarPainter extends CustomPainter {
  final double progress;
  final double startAngle;
  final double sweepAngle;
  final Color progressColor;

  CurvedProgressBarPainter({
    required this.progress,
    required this.startAngle,
    required this.sweepAngle,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Rect rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2);

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);
    double angle = (progress / 100) * sweepAngle;
    canvas.drawArc(rect, startAngle, angle, false, progressPaint);
  }

  @override
  bool shouldRepaint(CurvedProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> userProgressFuture;

  Color _backgroundColor = Colors.white;
  String _selectedColorName = 'Light Blue';
  bool _isTimerEnabled = false;

  final Map<String, Color> availableColors = {
    'White': Colors.white,
    'Light Grey': Colors.grey.shade100,
    'Beige': Color(0xFFFFF8E1),
    'Light Blue': Color(0xFFE3F2FD),
    'Mint Green': Color(0xFFE0F2F1),
    'Light Blue Accent': Colors.lightBlueAccent,
  };

  @override
  void initState() {
    super.initState();
    userProgressFuture = fetchUserProgress();
    loadBackgroundColor();
    loadTimerPreference();
  }

  Future<void> loadBackgroundColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorName = prefs.getString('background_color') ?? 'Light Blue';

    // Check if colorName exists in availableColors, else fallback to 'White'
    final isValidColor = availableColors.containsKey(colorName);
    final finalColorName = isValidColor ? colorName : 'White';

    setState(() {
      _selectedColorName = finalColorName;
      _backgroundColor = availableColors[finalColorName]!;
    });

    if (!isValidColor) {
      // Save the fallback color back to preferences
      await prefs.setString('background_color', finalColorName);
    }
  }

  Future<void> saveBackgroundColor(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('background_color', colorName);
  }

  Future<Map<String, dynamic>> fetchUserProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username == null) return {};

    final response =
        await Supabase.instance.client.from('users_data').select('''
      username,
      user_points,
      safe_internet_usage_questions_beginner, safe_internet_usage_questions_intermediate, safe_internet_usage_questions_advanced,
      cyber_hygiene_questions_beginner, cyber_hygiene_questions_intermediate, cyber_hygiene_questions_advanced,
      social_cyber_attaches_questions_beginner, social_cyber_attaches_questions_intermediate, social_cyber_attaches_questions_advanced,
      basic_email_security_questions_beginner, basic_email_security_questions_intermediate, basic_email_security_questions_advanced,
      social_media_security_questions_beginner, social_media_security_questions_intermediate, social_media_security_questions_advanced,
      recognizing_social_engineering_questions_beginner, recognizing_social_engineering_questions_intermediate, recognizing_social_engineering_questions_advanced,
      gdpr_questions_beginner, gdpr_questions_intermediate, gdpr_questions_advanced,
      privacy_safety_and_security_questions_beginner, privacy_safety_and_security_questions_intermediate, privacy_safety_and_security_questions_advanced,
      iot_and_ai_in_cybersecurity_questions_beginner, iot_and_ai_in_cybersecurity_questions_intermediate, iot_and_ai_in_cybersecurity_questions_advanced
    ''').eq('username', username).single();

    return response;
  }

  double calculateProgress(Map<String, dynamic> data) {
    int completed = 0;
    int total = 0;

    data.forEach((key, value) {
      if (key == 'username' || key == 'user_points') return; // Exclude user_points

      total++;
      if (value == true) completed++;
    });

    return total == 0 ? 0.0 : (completed / total) * 100; // Avoid division by zero
  }

  Map<String, double> calculateModeProgress(Map<String, dynamic> data) {
    Map<String, int> total = {'beginner': 0, 'intermediate': 0, 'advanced': 0};
    Map<String, int> completed = {
      'beginner': 0,
      'intermediate': 0,
      'advanced': 0
    };

    data.forEach((key, value) {
      if (key == 'username'|| key == 'user_points') return;

      if (key.endsWith('_beginner')) {
        total['beginner'] = total['beginner']! + 1;
        if (value == true) completed['beginner'] = completed['beginner']! + 1;
      } else if (key.endsWith('_intermediate')) {
        total['intermediate'] = total['intermediate']! + 1;
        if (value == true)
          completed['intermediate'] = completed['intermediate']! + 1;
      } else if (key.endsWith('_advanced')) {
        total['advanced'] = total['advanced']! + 1;
        if (value == true) completed['advanced'] = completed['advanced']! + 1;
      }
    });

    return {
      'Beginner': (completed['beginner']! / total['beginner']!) * 100,
      'Intermediate':
          (completed['intermediate']! / total['intermediate']!) * 100,
      'Advanced': (completed['advanced']! / total['advanced']!) * 100,
    };
  }

  Color getProgressColor(double progress) {
    if (progress < 50) {
      return Color.lerp(Colors.yellow, Color(0xFFF1B05B), progress / 50)!;
    } else if (progress < 100) {
      return Color.lerp(
          Colors.orange, Colors.deepOrangeAccent, (progress - 50) / 50)!;
    } else {
      return Colors.green;
    }
  }

  Future<void> loadTimerPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTimerEnabled = prefs.getBool('quiz_timer_enabled') ?? false;
    });
  }

  Future<void> saveTimerPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_timer_enabled', value);
  }

  Widget buildProgressBar(double progress,
      {String label = "Overall\nProgress", double size = 100}) {
    Color progressColor = getProgressColor(progress);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        CustomPaint(
          size: Size(size, size),
          painter: CurvedProgressBarPainter(
            progress: progress,
            startAngle: -3.14 / 2,
            sweepAngle: 6.28,
            progressColor: progressColor,
          ),
        ),
      ],
    );
  }

  bool isAdvancedCompleted(Map<String, dynamic> progress) {
    final advancedQuizzes = [
      'safe_internet_usage_questions_advanced',
      'cyber_hygiene_questions_advanced',
      'social_cyber_attaches_questions_advanced',
      'basic_email_security_questions_advanced',
      'social_media_security_questions_advanced',
      'recognizing_social_engineering_questions_advanced',
      'gdpr_questions_advanced',
      'privacy_safety_and_security_questions_advanced',
      'iot_and_ai_in_cybersecurity_questions_advanced'
    ];

    for (var quiz in advancedQuizzes) {
      if (progress[quiz] != true) {
        return false;
      }
    }

    return true;
  }

  Future<void> generateCertificate(
      String username, Map<String, dynamic> progress) async {
    if (!isAdvancedCompleted(progress)) return;

    TextEditingController nameController =
        TextEditingController(text: username);
    String? enteredName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Name for Certificate'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: "Enter your name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(nameController.text),
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (enteredName == null || enteredName.isEmpty) return;

    double advancedProgress = calculateModeProgress(progress)['Advanced'] ?? 0;
    final ByteData bytes = await rootBundle.load('assets/AppImage.png');
    final Uint8List imageData = bytes.buffer.asUint8List();
    final image = pw.MemoryImage(imageData);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Image(image, height: 300),
                pw.SizedBox(height: 30),
                pw.Text('Certificate of Achievement',
                    style: pw.TextStyle(
                        fontSize: 30, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.Text('This is to certify that',
                    style: pw.TextStyle(fontSize: 20)),
                pw.SizedBox(height: 5),
                pw.Text(enteredName,
                    style: pw.TextStyle(
                        fontSize: 25, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text(
                    'has successfully completed the advanced level of NetSecured with a score of more than 70% on all Advanced Quizzes',
                    style: pw.TextStyle(fontSize: 20),
                    textAlign: pw.TextAlign.center),
                pw.SizedBox(height: 10),
                pw.Text('Date: ${DateTime.now().toLocal()}',
                    style: pw.TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/certificate_$username.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;

    // Handle guest users or logged-out state
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.black),
              SizedBox(height: 20),
              Text(
                "You are currently a guest.",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Please sign in to unlock this feature.",
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Container(
                width: 150,
                height: 40,
                margin: const EdgeInsets.only(top: 20),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xff6200EE),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: userProgressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          Map<String, dynamic> progress = snapshot.data ?? {};
          String username = progress["username"] ?? "Unknown";
          double progressPercentage = calculateProgress(progress);

          final quizMap = <String, Map<String, bool>>{};
          progress.forEach((key, value) {
            if (key == 'username') return;

            final quizPrefix = key.replaceAll(
                RegExp(r'_(beginner|intermediate|advanced)$'), '');
            final level = key.split('_').last;

            quizMap[quizPrefix] ??= {};
            quizMap[quizPrefix]![level] = value == true;
          });

          return Container(
            color: context.watch<ThemeProvider>().availableColors[
                context.watch<ThemeProvider>().selectedColorName],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    FluttermojiCircleAvatar(radius: 100),
                    const SizedBox(height: 20),
                    const Text("Account",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Username: $username',
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 5),
                    Text('Points: ${progress["user_points"] ?? 0}',
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      style:  ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          const Color(0xff6200EE),
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          Colors.white,
                        )
                      ),
                      onPressed: () {
                        logout();
                      },
                      child: const Text('Sign Out'),
                    ),
                    const SizedBox(height: 20),
                    const Text("Overall Progress",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    buildProgressBar(progressPercentage, size: 120),
                    const SizedBox(height: 30),
                    const Text("Mode Progress",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children:
                          calculateModeProgress(progress).entries.map((entry) {
                        return buildProgressBar(entry.value,
                            label: entry.key, size: 100);
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text("Category Progress",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: quizMap.entries
                          .where((entry) => entry.key != 'user_points')
                          .map((entry) {
                        String quizTitle = entry.key
                            .replaceAll('_questions', '')
                            .split('_')
                            .map((word) {
                          return word == 'gdpr'
                              ? 'GDPR'
                              : word[0].toUpperCase() + word.substring(1);
                        }).join(' ');

                        Map<String, bool> levels = entry.value;
                        int total = levels.length;
                        int completed = levels.values.where((done) => done).length;
                        double categoryProgress = (completed / total) * 100;

                        return buildProgressBar(categoryProgress,
                            label: quizTitle, size: 100);
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    const Text("Quiz Timer",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text("Enable Timer for Quizzes"),
                      value: _isTimerEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _isTimerEnabled = value;
                        });
                        saveTimerPreference(value);
                      },
                    ),
                    const SizedBox(height: 30),
                    const Text("Customize Background",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: context.watch<ThemeProvider>().selectedColorName,
                      items: context
                          .watch<ThemeProvider>()
                          .availableColors
                          .keys
                          .map((String colorName) {
                        return DropdownMenuItem<String>(
                          value: colorName,
                          child: Text(colorName),
                        );
                      }).toList(),
                      onChanged: (String? colorName) {
                        if (colorName != null) {
                          context
                              .read<ThemeProvider>()
                              .setBackgroundColor(colorName);
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 30),
                    const Text("Certificate",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff6200EE),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (!isAdvancedCompleted(progress)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'You must complete all advanced quizzes to download the certificate.')),
                          );
                          return;
                        }

                        await generateCertificate(username, progress);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Certificate generated successfully!')),
                        );
                      },
                      child: const Text('Download Certificate'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}
