import 'dart:async';
import 'dart:math';

class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 600),
    Future<void> Function(Duration duration)? delay,
  }) : _delay = delay ?? _defaultDelay;

  final int maxRetries;
  final Duration baseDelay;
  final Future<void> Function(Duration duration) _delay;

  static Future<void> _defaultDelay(Duration duration) =>
      Future.delayed(duration);

  Duration backoffFor(int attemptNumber) {
    return baseDelay * pow(2, attemptNumber).toInt();
  }

  Future<T> execute<T>(
    Future<T> Function() action, {
    required bool Function(Object error) isRetryable,
  }) async {
    var tries = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        if (tries >= maxRetries || !isRetryable(e)) rethrow;
      }
      tries++;
      await _delay(backoffFor(tries));
    }
  }
}
