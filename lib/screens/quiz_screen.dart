import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

enum QuizView { question, leaderboard, waiting }

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
  Timer? _pollTimer;

  int? _currentOrderIndex;
  bool _answered = false;



  QuizView _view = QuizView.question;
  List<dynamic> _leaderboard = [];

  Map<String, dynamic>? _question;
  late DateTime _shownAt;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
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

    // 👉 ОДРАЗУ показуємо leaderboard
    final leaderboard = await ApiService.getLeaderboard(widget.sessionId);

    if (!mounted) return;

    setState(() {
      _answered = true;
      _view = QuizView.leaderboard;
      _leaderboard = leaderboard;
      _currentOrderIndex = _question!['orderIndex'];
    });

    // ⏳ через 3 секунди повертаємось у режим очікування
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        _view = QuizView.question;
      });
    });
  }

  void _startPolling() {
  _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
    final question =
        await ApiService.getCurrentQuestion(widget.sessionId);

    if (!mounted) return;

    // перше питання
    if (_question == null) {
      setState(() {
        _question = question;
        _currentOrderIndex = question['orderIndex'];
        _shownAt = DateTime.now();
      });
      return;
    }

    // нове питання
    if (_currentOrderIndex != question['orderIndex']) {
      setState(() {
        _question = question;
        _currentOrderIndex = question['orderIndex'];
        _answered = false;
        _shownAt = DateTime.now();
        _view = QuizView.question;
      });
    }
  });
}
  

  @override
  Widget build(BuildContext context) {
    if (_view == QuizView.leaderboard) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leaderboard')),
        body: ListView.builder(
          itemCount: _leaderboard.length,
          itemBuilder: (context, index) {
            final p = _leaderboard[index];
            return ListTile(
              leading: Text('#${p['rank']}'),
              title: Text(p['nickname']),
              trailing: Text('${p['totalPoints']} pts'),
            );
          },
        ),
      );
    }

    if (_view == QuizView.waiting) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Waiting for next question...',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    if (_question == null) {
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
