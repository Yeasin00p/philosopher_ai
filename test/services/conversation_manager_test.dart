import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/services/conversation_manager.dart';

void main() {
  late ConversationManager manager;

  setUp(() {
    manager = ConversationManager(maxTurns: 2); // maxMessages = 4
  });

  test('maxTurns এর মধ্যে থাকলে droppedCount শূন্য থাকে', () {
    manager.addUserMessage('প্রশ্ন ১');
    manager.addAssistantMessage('উত্তর ১');
    manager.addUserMessage('প্রশ্ন ২');
    manager.addAssistantMessage('উত্তর ২');

    expect(manager.history.length, 4);
    expect(manager.droppedCount, 0);
  });

  test('maxTurns ছাড়িয়ে গেলে পুরনো turn trim হয় এবং droppedCount বাড়ে', () {
    manager.addUserMessage('প্রশ্ন ১');
    manager.addAssistantMessage('উত্তর ১');
    manager.addUserMessage('প্রশ্ন ২');
    manager.addAssistantMessage('উত্তর ২');
    manager.addUserMessage('প্রশ্ন ৩');
    manager.addAssistantMessage('উত্তর ৩');

    expect(manager.history.length, 4);
    expect(manager.history.first['content'], 'প্রশ্ন ২');
    expect(manager.droppedCount, 2);
  });

  test('একাধিকবার trim হলে droppedCount cumulative ভাবে বাড়ে', () {
    for (var i = 1; i <= 6; i++) {
      manager.addUserMessage('প্রশ্ন $i');
      manager.addAssistantMessage('উত্তর $i');
    }

    expect(manager.history.length, 4);
    expect(manager.droppedCount, 8);
  });

  test('clear() করলে droppedCount রিসেট হয়', () {
    manager.addUserMessage('প্রশ্ন ১');
    manager.addAssistantMessage('উত্তর ১');
    manager.addUserMessage('প্রশ্ন ২');
    manager.addAssistantMessage('উত্তর ২');
    manager.addUserMessage('প্রশ্ন ৩');
    manager.addAssistantMessage('উত্তর ৩');

    expect(manager.droppedCount, greaterThan(0));

    manager.clear();

    expect(manager.droppedCount, 0);
    expect(manager.history, isEmpty);
  });

  test('removeLastUserMessageIfPresent() droppedCount বদলায় না', () {
    manager.addUserMessage('প্রশ্ন ১');
    manager.removeLastUserMessageIfPresent();

    expect(manager.history, isEmpty);
    expect(manager.droppedCount, 0);
  });
}
