import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/screens/widget/context_notice.dart';

void main() {
  testWidgets('ContextNotice বার্তা প্রদর্শন করে', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ContextNotice())),
    );

    expect(
      find.textContaining('মার্কাস আর মনে রাখছেন না'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.history_toggle_off_rounded), findsOneWidget);
  });
}