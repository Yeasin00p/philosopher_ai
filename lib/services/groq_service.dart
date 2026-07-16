import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:philosopher_ai/config.dart';
import 'package:philosopher_ai/services/chat_completion_service.dart';
import 'package:philosopher_ai/services/user_facing_exception.dart';
import 'retry_policy.dart';
import 'session_id_service.dart';

class NetworkException implements Exception, UserFacingException {
  final String message;
  NetworkException(this.message);

  @override
  String get userMessage => message;

  @override
  String toString() => message;
}

class ApiException implements Exception, UserFacingException {
  final String message;
  final int? statusCode;
  final bool isUsageLimit;
  final DateTime? resetsAt;

  ApiException(
    this.message, {
    this.statusCode,
    this.isUsageLimit = false,
    this.resetsAt,
  });

  @override
  String get userMessage => message;

  @override
  String toString() => message;
}

class GroqService implements ChatCompletionService {
  GroqService({http.Client? client, RetryPolicy? retryPolicy})
    : _client = client ?? http.Client(),
      _retryPolicy = retryPolicy ?? const RetryPolicy();

  static const String _baseUrl = AppConfig.proxyUrl;
  static const String _model = 'llama-3.3-70b-versatile';
  static const Duration _requestTimeout = Duration(seconds: 30);

  final http.Client _client;
  final RetryPolicy _retryPolicy;

  @override
  Future<String> complete(
    List<Map<String, String>> messages, {
    double temperature = 1.1,
    double topP = 0.92,
    int maxTokens = 1024,
  }) {
    return _retryPolicy.execute(
      () => _call(
        messages,
        temperature: temperature,
        topP: topP,
        maxTokens: maxTokens,
      ),
      isRetryable: _isRetryable,
    );
  }

  bool _isRetryable(Object e) {
    if (e is ApiException) {
      return !e.isUsageLimit &&
          (e.statusCode == 429 || (e.statusCode ?? 0) >= 500);
    }
    return e is NetworkException;
  }

  Future<String> _call(
    List<Map<String, String>> messages, {
    required double temperature,
    required double topP,
    required int maxTokens,
  }) async {
    final sessionId = await SessionIdService.instance.getOrCreate();

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'x-app-secret': AppConfig.appSecret,
              'x-session-id': sessionId,
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
        'সার্ভার থেকে উত্তর আসতে অনেক সময় লাগছে। ইন্টারনেট সংযোগ পরীক্ষা করুন।',
      );
    } catch (e) {
      throw NetworkException('নেটওয়ার্ক সংযোগে সমস্যা হয়েছে: $e');
    }

    if (response.statusCode == 429) {
      throw _handle429(response);
    }

    if (response.statusCode != 200) {
      throw ApiException(
        _messageForStatus(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final text = data['choices']?[0]?['message']?['content'] as String?;

    if (text == null || text.trim().isEmpty) {
      throw ApiException(
        'দার্শনিক এই মুহূর্তে নীরব — অনুগ্রহ করে আবার চেষ্টা করুন।',
      );
    }
    return text;
  }

  ApiException _handle429(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['error'] == 'usage_limit_reached') {
        final resetsAt = DateTime.parse(data['resets_at'] as String).toLocal();
        return ApiException(
          _usageLimitMessage(resetsAt),
          statusCode: 429,
          isUsageLimit: true,
          resetsAt: resetsAt,
        );
      }
    } catch (_) {}
    return ApiException(_messageForStatus(429), statusCode: 429);
  }

  String _usageLimitMessage(DateTime resetsAt) {
    final remaining = resetsAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return 'আপনার এই দফার সীমা শেষ — এখনই আবার চেষ্টা করুন।';
    }
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final timeStr = hours > 0
        ? '$hours ঘণ্টা ${minutes > 0 ? '$minutes মিনিট ' : ''}পর'
        : '$minutes মিনিট পর';
    return 'আপনি এই দফায় যথেষ্ট কথা বলে ফেলেছেন। প্রায় $timeStr আবার কথা বলতে পারবেন।';
  }

  String _messageForStatus(int statusCode) {
    switch (statusCode) {
      case 401:
      case 403:
        return 'সার্ভার অনুরোধ গ্রহণ করেনি। কিছুক্ষণ পর আবার চেষ্টা করুন।';
      case 429:
        return 'অনুরোধের হার সীমা ছাড়িয়ে গেছে। কিছুক্ষণ পর আবার চেষ্টা করুন।';
      default:
        return 'সার্ভার ত্রুটি ($statusCode)। পরে আবার চেষ্টা করুন।';
    }
  }

  @override
  void dispose() {
    _client.close();
  }
}