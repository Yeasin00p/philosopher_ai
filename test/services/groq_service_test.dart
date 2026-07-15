import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:philosopher_ai/services/groq_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // SessionIdService reads/writes a session id via SharedPreferences.
    SharedPreferences.setMockInitialValues({});
  });

  final messages = [
    {'role': 'user', 'content': 'হ্যালো'},
  ];

  http.Response chatResponse(String content) => http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'content': content},
            },
          ],
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  group('GroqService.complete', () {
    test('returns the model reply on a successful call', () async {
      final service = GroqService(
        client: MockClient((request) async {
          return chatResponse('স্বাগতম, বন্ধু।');
        }),
      );

      final reply = await service.complete(messages);

      expect(reply, 'স্বাগতম, বন্ধু।');
    });

    test('throws ApiException when the reply content is empty', () async {
      final service = GroqService(
        client: MockClient((request) async => chatResponse('')),
      );

      expect(
        () => service.complete(messages),
        throwsA(isA<ApiException>()),
      );
    });

    test('wraps client-thrown errors as NetworkException', () async {
      final service = GroqService(
        client: MockClient((request) async {
          throw Exception('socket closed');
        }),
      );

      expect(
        () => service.complete(messages),
        throwsA(isA<NetworkException>()),
      );
    });

    test('401 fails immediately without retrying', () async {
      var callCount = 0;
      final service = GroqService(
        client: MockClient((request) async {
          callCount++;
          return http.Response('{"error":"unauthorized"}', 401);
        }),
      );

      await expectLater(
        () => service.complete(messages),
        throwsA(isA<ApiException>()),
      );
      expect(callCount, 1);
    });

    test('usage_limit_reached 429 fails immediately without retrying', () async {
      var callCount = 0;
      final resetsAt = DateTime.now().add(const Duration(hours: 2));
      final service = GroqService(
        client: MockClient((request) async {
          callCount++;
          return http.Response(
            jsonEncode({
              'error': 'usage_limit_reached',
              'resets_at': resetsAt.toIso8601String(),
            }),
            429,
          );
        }),
      );

      Object? caught;
      try {
        await service.complete(messages);
      } catch (e) {
        caught = e;
      }

      expect(caught, isA<ApiException>());
      expect((caught as ApiException).isUsageLimit, isTrue);
      expect(callCount, 1);
    });

    test('plain 429 (rate limit) retries up to maxRetries then throws', () async {
      var callCount = 0;
      final service = GroqService(
        client: MockClient((request) async {
          callCount++;
          return http.Response('{"error":"rate_limited"}', 429);
        }),
      );

      await expectLater(
        () => service.complete(messages),
        throwsA(isA<ApiException>()),
      );
      // Initial attempt + 2 retries = 3 total calls.
      expect(callCount, 3);
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('5xx server errors retry up to maxRetries then throw', () async {
      var callCount = 0;
      final service = GroqService(
        client: MockClient((request) async {
          callCount++;
          return http.Response('{"error":"server_error"}', 503);
        }),
      );

      await expectLater(
        () => service.complete(messages),
        throwsA(isA<ApiException>()),
      );
      expect(callCount, 3);
    }, timeout: const Timeout(Duration(seconds: 15)));

    test('succeeds after a transient 5xx followed by a 200', () async {
      var callCount = 0;
      final service = GroqService(
        client: MockClient((request) async {
          callCount++;
          if (callCount == 1) {
            return http.Response('{"error":"server_error"}', 503);
          }
          return chatResponse('এবার উত্তর এলো।');
        }),
      );

      final reply = await service.complete(messages);

      expect(reply, 'এবার উত্তর এলো।');
      expect(callCount, 2);
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}