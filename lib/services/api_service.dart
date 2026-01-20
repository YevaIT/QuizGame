import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://kahoot-api.mercantec.tech/api';

  static Future<Map<String, dynamic>> joinSession({
    required String pin,
    required String nickname,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/quizsession/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sessionPin': pin, 'nickname': nickname}),
    );

    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 404) {
      throw Exception('Session not found');
    }

    if (response.statusCode == 409) {
      throw Exception('Nickname already taken');
    }

    throw Exception('Failed to join session');
  }

  static Future<Map<String, dynamic>> getSessionById(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/quizsession/$sessionId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load session');
  }

  static Future<Map<String, dynamic>> getCurrentQuestion(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/participant/session/$sessionId/current-question'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load question');
  }

  static Future<void> submitAnswer({
    required int participantId,
    required int questionId,
    required int answerId,
    required int responseTimeMs,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/participant/submit-answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'participantId': participantId,
        'questionId': questionId,
        'answerId': answerId,
        'responseTimeMs': responseTimeMs,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw Exception('Failed to submit answer');
  }

  static Future<List<dynamic>> getLeaderboard(int sessionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/participant/leaderboard/$sessionId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to load leaderboard');
  }
}
