import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:philosopher_ai/config.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

/// Thin wrapper around the Groq chat-completions endpoint. Knows nothing
/// about personas, prompts, or conversation history — it only turns a
/// list of `{role, content}` messages into a reply, with timeout,
/// backoff/retry, and error translation into the app's own exception
/// types.
class GroqService {
  GroqService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  final http.Client _client;

  Future<String> complete(
    List<Map<String, String>> messages, {
    double temperature = 1.1,
    double topP = 0.92,
    int maxTokens = 1024,
  }) {
    return _withRetry(() => _call(
          messages,
          temperature: temperature,
          topP: topP,
          maxTokens: maxTokens,
        ));
  }

  /// Retries rate-limit (429), server errors (5xx), and transient network
  /// failures with exponential backoff. Anything else (bad request, empty
  /// reply, auth failure) is not worth retrying and surfaces immediately.
  Future<String> _withRetry(Future<String> Function() attempt) async {
    var tries = 0;
    while (true) {
      try {
        return await attempt();
      } on ApiException catch (e) {
        final retryable =
            e.statusCode == 429 || (e.statusCode ?? 0) >= 500;
        if (!retryable || tries >= _maxRetries) rethrow;
      } on NetworkException {
        if (tries >= _maxRetries) rethrow;
      }
      tries++;
      await Future.delayed(Duration(milliseconds: 600 * pow(2, tries).toInt()));
    }
  }

  Future<String> _call(
    List<Map<String, String>> messages, {
    required double temperature,
    required double topP,
    required int maxTokens,
  }) async {
    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer ${AppConfig.gorqApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': messages,
              'temperature': temperature,
              'top_p': topP,
              'max_tokens': maxTokens,
              'frequency_penalty': 0.4,
              'presence_penalty': 0.3,
            }),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw NetworkException(
          'সার্ভার থেকে উত্তর আসতে অনেক সময় লাগছে। ইন্টারনেট সংযোগ পরীক্ষা করুন।');
    } catch (e) {
      throw NetworkException('নেটওয়ার্ক সংযোগে সমস্যা হয়েছে: $e');
    }

    if (response.statusCode != 200) {
      throw ApiException(_messageForStatus(response.statusCode),
          statusCode: response.statusCode);
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final text = data['choices']?[0]?['message']?['content'] as String?;

    if (text == null || text.trim().isEmpty) {
      throw ApiException('দার্শনিক এই মুহূর্তে নীরব — অনুগ্রহ করে আবার চেষ্টা করুন।');
    }
    return text;
  }

  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'API কী সঠিক নয়। অনুগ্রহ করে কনফিগারেশন পরীক্ষা করুন।';
      case 429:
        return 'অনুরোধের হার সীমা ছাড়িয়ে গেছে। কিছুক্ষণ পর আবার চেষ্টা করুন।';
      default:
        return 'সার্ভার ত্রুটি ($statusCode)। পরে আবার চেষ্টা করুন।';
    }
  }

  void dispose() {
    _client.close();
  }
}