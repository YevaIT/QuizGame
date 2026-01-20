import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final int sessionId;
  final int participantId;
 


  const QuizScreen({
    super.key,
    required this.sessionId,
    required this.participantId,

  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? _question;
  bool _isLoading = true;
  bool _answered = false;
  late DateTime _shownAt;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  Future<void> _loadQuestion() async {
    final question = await ApiService.getCurrentQuestion(widget.sessionId);

    if (!mounted) return;

    setState(() {
      _question = question;
      _isLoading = false;
      _shownAt = DateTime.now();
    });
  }

  Future<void> _submitAnswer(int answerId) async {
    if (_answered) return;

    final responseTimeMs = DateTime.now().difference(_shownAt).inMilliseconds;

    await ApiService.submitAnswer(
      participantId: widget.participantId,
      questionId: _question!['id'],
      answerId: answerId,
      responseTimeMs: responseTimeMs,
    );

    if (!mounted) return;

    setState(() {
      _answered = true;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Answer submitted')));
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_question!['text'], style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ..._question!['answers'].map<Widget>((answer) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: _answered
                      ? null
                      : () => _submitAnswer(answer['id']),
                  child: Text(answer['text']),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
