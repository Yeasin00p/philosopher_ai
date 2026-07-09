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

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  
  static const int _maxHistoryTurns = 12; 

  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxRetries = 2;

  static const String _systemPrompt = '''
আপনি মার্কাস অরেলিয়াস — রোমান সম্রাট এবং স্টোয়িক দার্শনিক (১২১–১৮০ খ্রিস্টাব্দ)।
আপনি একজন শাসক এবং চিন্তাবিদ হিসেবে নিজের বাস্তব অভিজ্ঞতা থেকে কথা বলেন।

গুরুত্বপূর্ণ নিয়ম: আপনাকে সবসময় বাংলা ভাষায় উত্তর দিতে হবে। প্রতিটি উত্তর সম্পূর্ণভাবে বাংলা লিপিতে লেখা থাকতে হবে। কোনো ব্যতিক্রম নেই — ব্যবহারকারী ইংরেজি বা অন্য যেকোনো ভাষায় লিখলেও আপনি বাংলায় উত্তর দেবেন।

কথা বলার ধরন:
- সবসময় প্রথম পুরুষে (আমি/আমার) মার্কাস অরেলিয়াস হিসেবে কথা বলুন।
- "Meditations" গ্রন্থের দর্শন থেকে অনুপ্রাণিত হয়ে কথা বলুন, তবে প্রতিটি উত্তরে বই থেকে উদ্ধৃতি দেওয়ার দরকার নেই — মাঝে মাঝে দিলেই যথেষ্ট।
- জ্ঞানী, শান্ত, উষ্ণ এবং চিন্তাশীল থাকুন — কখনো উপদেশ-বাণী আওড়ানোর মতো (preachy) মনে হবে না।
- রোমান জীবনের প্রাসঙ্গিক উপমা বা ছবি ব্যবহার করুন, কিন্তু জোর করে নয়।

গুণগত মান নিশ্চিত করার নির্দেশনা (এগুলো অত্যন্ত গুরুত্বপূর্ণ):
- ব্যবহারকারী ঠিক কী বলেছে বা জিজ্ঞাসা করেছে তার সাথে সরাসরি সংযোগ রেখে উত্তর দিন। সাধারণ, টেমপ্লেটের মতো উত্তর এড়িয়ে চলুন।
- আগের কথোপকথনের প্রসঙ্গ মনে রাখুন এবং তার সাথে ধারাবাহিকতা বজায় রাখুন — একই কথা বা একই উপমা বারবার ব্যবহার করবেন না।
- প্রতিটি উত্তরে নতুন কিছু দিন — নতুন দৃষ্টিভঙ্গি, নতুন উদাহরণ, বা একটি নির্দিষ্ট প্রশ্ন — যাতে কথোপকথন এগিয়ে যায়, থেমে না থাকে।
- উত্তর সংক্ষিপ্ত রাখুন — সাধারণত ২-৪টি অনুচ্ছেদ, যদি না ব্যবহারকারী গভীর আলোচনা চান।
- আধুনিক বিষয় নিয়ে প্রশ্ন এলে সেগুলোকে চিরন্তন স্টোয়িক নীতির সাথে জুড়ে বাস্তবসম্মতভাবে ব্যাখ্যা করুন, শুধু তত্ত্ব আউড়াবেন না।
- মাঝে মাঝে একটি সক্রেটিক প্রশ্ন করে ব্যবহারকারীকে ভাবতে উদ্বুদ্ধ করুন, কিন্তু প্রতি উত্তরে নয় — তাহলে কৃত্রিম মনে হবে।
- ব্যবহারকারী দুঃখ, উদ্বেগ বা কষ্টের কথা বললে প্রথমে তার অনুভূতি স্বীকার করুন, তারপর দর্শনের দিকে যান — সরাসরি উপদেশ দিয়ে শুরু করবেন না।
''';

  final List<Map<String, String>> _history = [];

  void _trimHistory() {
    final maxMessages = _maxHistoryTurns * 2;
    if (_history.length > maxMessages) {
      _history.removeRange(0, _history.length - maxMessages);
    }
  }

  Future<String> sendMessage(String userMessage) async {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) {
      throw ApiException('বার্তা খালি রাখা যাবে না।');
    }

    _history.add({'role': 'user', 'content': trimmed});
    _trimHistory();

    try {
      final text = await _callWithRetry();
      _history.add({'role': 'assistant', 'content': text});
      _trimHistory();
      return text;
    } catch (e) {
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      rethrow;
    }
  }

  Future<String> _callWithRetry() async {
    int attempt = 0;
    while (true) {
      try {
        return await _callGroqApi();
      } on ApiException catch (e) {
        final isRateLimited = e.statusCode == 429;
        final isServerError = (e.statusCode ?? 0) >= 500;
        if ((isRateLimited || isServerError) && attempt < _maxRetries) {
          attempt++;
          final backoff = Duration(milliseconds: 600 * pow(2, attempt).toInt());
          await Future.delayed(backoff);
          continue;
        }
        rethrow;
      }
    }
  }

  Future<String> _callGroqApi() async {
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer ${AppConfig.gorqApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                ..._history,
              ],
              'temperature': 0.8,
              'top_p': 0.92,
              'max_tokens': 1024,
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
      String message;
      switch (response.statusCode) {
        case 401:
          message = 'API কী সঠিক নয়। অনুগ্রহ করে কনফিগারেশন পরীক্ষা করুন।';
          break;
        case 429:
          message = 'অনুরোধের হার সীমা ছাড়িয়ে গেছে। কিছুক্ষণ পর আবার চেষ্টা করুন।';
          break;
        default:
          message = 'সার্ভার ত্রুটি (${response.statusCode})। পরে আবার চেষ্টা করুন।';
      }
      throw ApiException(message, statusCode: response.statusCode);
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final text = data['choices']?[0]?['message']?['content'] as String?;

    if (text == null || text.trim().isEmpty) {
      throw ApiException('দার্শনিক এই মুহূর্তে নীরব — অনুগ্রহ করে আবার চেষ্টা করুন।');
    }

    return text;
  }

  Future<String> getGreeting() async {
    return sendMessage(
      'ব্যবহারকারী মাত্র আপনার সাথে কথা বলতে এসেছেন, এটাই তাদের প্রথমবার। '
      'মার্কাস অরেলিয়াসের মতো ২-৩ বাক্যে তাদের উষ্ণভাবে অভ্যর্থনা জানান। '
      'কথোপকথনে স্বাগত জানান এবং তাদের মনে যা আছে তা ভাগ করে নেওয়ার আমন্ত্রণ জানান।',
    );
  }

  void clearHistory() {
    _history.clear();
  }

  List<Map<String, String>> get history => List.unmodifiable(_history);

  void dispose() {}
}