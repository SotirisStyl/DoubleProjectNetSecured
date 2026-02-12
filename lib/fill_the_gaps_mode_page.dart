import 'package:flutter/material.dart';
import 'package:cs_app2/fill_the_gaps_page.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class FillTheGapsModePage extends StatelessWidget {
  const FillTheGapsModePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text("Fill the Gaps"),
        backgroundColor: const Color(0xff6200EE),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Select Difficulty",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildDifficultyButton(context, "Easy", "fill_the_gaps_easy", Colors.green),
            const SizedBox(height: 20),
            _buildDifficultyButton(context, "Medium", "fill_the_gaps_medium", Colors.orange),
            const SizedBox(height: 20),
            _buildDifficultyButton(context, "Hard", "fill_the_gaps_hard", Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String label, String table, Color color) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FillTheGapsPage(tableName: table, difficulty: label.toLowerCase()),
            ),
          );
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}