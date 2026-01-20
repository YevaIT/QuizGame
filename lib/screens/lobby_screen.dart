import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_game/screens/quiz_screen.dart';
import '../services/api_service.dart';

class LobbyScreen extends StatefulWidget {
  final int sessionId;
  final int participantId;

  const LobbyScreen({super.key, required this.sessionId, required this.participantId});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  Timer? _timer;
  String _status = 'Waiting';
  int _participantCount = 0;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final session = await ApiService.getSessionById(widget.sessionId);

        if (!mounted) return;

        setState(() {
          _status = session['status'];
          _participantCount = session['participantCount'] ?? 0;
        });

        if (_status == 'InProgress') {
  _timer?.cancel();

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => QuizScreen(
        sessionId: widget.sessionId,
        participantId: widget.participantId,
      ),
    ),
  );
}
      } catch (_) {
        // тимчасово ігноруємо
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Waiting for host to start...',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text('Participants: $_participantCount'),
            const SizedBox(height: 20),
            Text('Status: $_status'),
          ],
        ),
      ),
    );
  }
}
