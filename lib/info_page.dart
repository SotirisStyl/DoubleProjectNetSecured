import 'package:flutter/material.dart';


class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 20),
            Text(
              "This page outlines the important information that are needed in order to enjoy NetSecured.\n",
            ),
            Text(
              "Purpose",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "1. NetSecured is a mobile application that allows users to learn about cybersecurity and network security.\n",
            ),
            Text("There are two main features of NetSecured:"),
            Text("1. Learn about different concepts of cybersecurity"),
            Text("2. Quiz yourself on network security\n"),
            Text(
              "How to use NetSecured",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("1. Sign up or log in to your account"),
            Text("2. Select the mode you want to play in"),
            Text("3. Select the topic you want to learn about"),
            Text("4. Read the introduction to the topic"),
            Text("5. Take the quiz\n"),
            Text(
              "How the quizzes work",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Points are gained for answering the questions correctly based on the difficulty of the quiz."),
            Text("• Beginner Quizzes grant 5 points"),
            Text("• Intermediate Quizzes grant 10 points"),
            Text("• Advanced Quizzes grant 20 points\n"),
            Text(
              "How to unlock the modes",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• Score 150 points in Beginner mode to unlock Intermediate mode."),
            Text("• Score 500 points in Beginner or Intermediate to unlock Advanced mode.\n"),
            Text(
              "Progress Tracker",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• There is an overall progress bar in order to track your overall progress."),
            Text("• Also, there is a progress bar for each mode, to track your progress in each mode.\n"),
            Text(
              "Badges",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• Earn badges by completing quizzes with over 70% correct answers."),
            Text("• Each quiz has a badge that changes color once completed."),
            Text("• Complete all three quizzes in a category to turn the badge green.\n"),
            Text(
              "Quiz Timer",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• There is a feature that when enabled, the timer will start a timer for 5 minutes when you start the quiz."),
            Text("• If the timer runs out, the quiz will end and you will not be able to submit your answers, causing you to lose the points gained from the quiz.\n"),
            Text(
              "Customize Background",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• There is a feature that allows you to customize the background of the app."),
            Text("• You can choose from a variety of colors to customize the background of the app.\n"),
            Text(
              "Certificate",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• The Certificate can only be unlocked through Advanced mode."),
            Text("• You must complete all advanced quizzes with at least 70% to earn it.\n\n"),
            Text(
              "Guest Account",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("• When using a Guest Account, features are limited."),
            Text("• You will be able to complete Beginner level quizzes only."),
            Text("• You will not be able to access the Profile Page, the Profile Customization Page, the Leaderboard, nor the Intermediate and Advanced mode quizzes.")
          ],
        ),
      ),
    );
  }
}
