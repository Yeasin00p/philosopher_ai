import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/main.dart';

void main() {
  testWidgets('App starts with splash screen', (tester) async {
    await tester.pumpWidget(const PhilosopherApp());

    // splash screen ঠিকমতো render হয়েছে কিনা যাচাই
    expect(find.text('WISDOM THROUGH DIALOGUE'), findsOneWidget);

    // pending timer (3s delayed navigation) শেষ করার জন্য যথেষ্ট সময় pump করুন,
    // নাহলে "Timer still pending" assertion আসবে।
    await tester.pump(const Duration(seconds: 4));
  });
}