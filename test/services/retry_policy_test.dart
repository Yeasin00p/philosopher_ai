import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/services/retry_policy.dart';

void main() {
  group('RetryPolicy', () {
    test('প্রথম চেষ্টাতেই সফল হলে রিট্রাই হয় না', () async {
      var callCount = 0;
      final recordedDelays = <Duration>[];

      final policy = RetryPolicy(
        maxRetries: 3,
        delay: (d) async => recordedDelays.add(d),
      );

      final result = await policy.execute<String>(
        () async {
          callCount++;
          return 'সফল';
        },
        isRetryable: (_) => true,
      );

      expect(result, 'সফল');
      expect(callCount, 1);
      expect(recordedDelays, isEmpty);
    });

    test('রিট্রাইযোগ্য এরর হলে সর্বোচ্চ maxRetries বার আবার চেষ্টা করে', () async {
      var callCount = 0;
      final recordedDelays = <Duration>[];

      final policy = RetryPolicy(
        maxRetries: 2,
        baseDelay: const Duration(milliseconds: 600),
        delay: (d) async => recordedDelays.add(d),
      );

      final result = await policy.execute<String>(
        () async {
          callCount++;
          if (callCount < 3) {
            throw Exception('সাময়িক ব্যর্থতা');
          }
          return 'অবশেষে সফল';
        },
        isRetryable: (_) => true,
      );

      // ৩ বার চেষ্টা: প্রথমটা + ২টা রিট্রাই
      expect(callCount, 3);
      expect(result, 'অবশেষে সফল');

      // Exponential backoff: baseDelay * 2^1, baseDelay * 2^2
      expect(recordedDelays, [
        const Duration(milliseconds: 1200),
        const Duration(milliseconds: 2400),
      ]);
    });

    test('রিট্রাই সীমা শেষ হয়ে গেলে শেষ এররটি rethrow করে', () async {
      var callCount = 0;

      final policy = RetryPolicy(
        maxRetries: 2,
        delay: (_) async {}, // instant, কোনো real wait নেই
      );

      expect(
        () => policy.execute<String>(
          () async {
            callCount++;
            throw Exception('এই ত্রুটি কখনো ঠিক হবে না');
          },
          isRetryable: (_) => true,
        ),
        throwsA(isA<Exception>()),
      );

      // await করে callCount চেক করি যেন async error সম্পূর্ণ হয়
      await expectLater(
        policy.execute<String>(
          () async {
            callCount++;
            throw Exception('আবার ব্যর্থ');
          },
          isRetryable: (_) => true,
        ),
        throwsA(isA<Exception>()),
      );

      // প্রথম ব্লকে ৩ বার (১ + ২ রিট্রাই), দ্বিতীয় ব্লকে আরও ৩ বার
      expect(callCount, 6);
    });

    test('রিট্রাইযোগ্য নয় এমন এরর সাথে সাথে rethrow করে, কোনো রিট্রাই হয় না', () async {
      var callCount = 0;
      final recordedDelays = <Duration>[];

      final policy = RetryPolicy(
        maxRetries: 3,
        delay: (d) async => recordedDelays.add(d),
      );

      await expectLater(
        policy.execute<String>(
          () async {
            callCount++;
            throw Exception('স্থায়ী ত্রুটি — রিট্রাই করা উচিত না');
          },
          isRetryable: (_) => false,
        ),
        throwsA(isA<Exception>()),
      );

      expect(callCount, 1);
      expect(recordedDelays, isEmpty);
    });

    test('backoffFor সঠিক exponential duration হিসাব করে', () {
      const policy = RetryPolicy(baseDelay: Duration(milliseconds: 500));

      expect(policy.backoffFor(1), const Duration(milliseconds: 1000));
      expect(policy.backoffFor(2), const Duration(milliseconds: 2000));
      expect(policy.backoffFor(3), const Duration(milliseconds: 4000));
    });

    test('ডিফল্ট maxRetries এবং baseDelay প্রত্যাশিত মান বহন করে', () {
      const policy = RetryPolicy();
      expect(policy.maxRetries, 2);
      expect(policy.baseDelay, const Duration(milliseconds: 600));
    });
  });
}