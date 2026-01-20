import 'package:flutter/material.dart';
import 'screens/join_screen.dart';

void main() {
  runApp(const QuizGameApp());
}

class QuizGameApp extends StatelessWidget {
  const QuizGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Quiz Game', home: const JoinScreen());
  }
}
