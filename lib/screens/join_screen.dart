import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'lobby_screen.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final _pinController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  Future<void> _join() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiService.joinSession(
        pin: _pinController.text,
        nickname: _nicknameController.text,
      );

      final participantId = result['id'];
      final sessionId = result['quizSessionId'];

      if (!mounted) return;

      debugPrint('Joined: $result');

     Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(sessionId: sessionId, participantId: participantId  ),
        ),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              decoration: const InputDecoration(labelText: 'Session PIN'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: 'Nickname'),
            ),
            const SizedBox(height: 20),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _isLoading ? null : _join,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
