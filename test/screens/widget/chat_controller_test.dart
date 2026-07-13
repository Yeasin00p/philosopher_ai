import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/screens/widget/chat_controller.dart';
import 'package:philosopher_ai/services/conversation_manager.dart';
import 'package:philosopher_ai/services/marcus_chat_service.dart';

import '../../fakes/fake_chat_completion_service.dart';

void main() {
  test('outOfContextCount শুরুতে ০, trim হওয়ার পর বাড়ে', () async {
    final fake = FakeChatCompletionService(replyToReturn: 'উত্তর');
    final service = MarcusChatService(
      chatService: fake,
      conversationManager: ConversationManager(maxTurns: 1), // maxMessages=2
    );
    final controller = ChatController(service: service);

    // greeting আগে থেকে না ডাকলেও send() কাজ করবে যেহেতু আমরা সরাসরি
    // send() টেস্ট করছি (loadGreeting আলাদা flow)।
    expect(controller.outOfContextCount, 0);

    await controller.send('প্রশ্ন ১');
    expect(controller.outOfContextCount, 0);

    await controller.send('প্রশ্ন ২'); // এবার trim হওয়ার কথা
    expect(controller.outOfContextCount, greaterThan(0));

    controller.dispose();
  });

  test(
    'ব্যর্থ বার্তার পরও outOfContextCount ঠিকভাবে reflect করে (dangling state নেই)',
    () async {
      final fake = FakeChatCompletionService(replyToReturn: 'উত্তর');
      final service = MarcusChatService(chatService: fake);
      final controller = ChatController(service: service);

      fake.shouldThrow = Exception('নেটওয়ার্ক সমস্যা');
      await controller.send('ব্যর্থ হবে এমন বার্তা');

      expect(controller.hasFailedMessage, isTrue);
      expect(controller.outOfContextCount, 0); // কিছুই trim হয়নি এখনো

      controller.dispose();
    },
  );
}
