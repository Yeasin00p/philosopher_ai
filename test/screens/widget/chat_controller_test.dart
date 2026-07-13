import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/di/service_locator.dart';
import 'package:philosopher_ai/screens/widget/chat_controller.dart';
import 'package:philosopher_ai/services/chat_completion_service.dart';
import 'package:philosopher_ai/services/conversation_manager.dart';
import 'package:philosopher_ai/services/marcus_chat_service.dart';

import '../../fakes/fake_chat_completion_service.dart';

void main() {
    group('DI composition root (get_it)', () {
    setUp(() {
      setupServiceLocator();
    });

    tearDown(() async {
      await resetServiceLocator();
    });

    test('getIt<ChatController>() override করা fake service ব্যবহার করে', () async {
      final fake = FakeChatCompletionService(replyToReturn: 'ফেইক উত্তর');

     
      getIt.unregister<ChatCompletionService>();
      getIt.registerLazySingleton<ChatCompletionService>(() => fake);

      final controller = getIt<ChatController>();
      await controller.send('হ্যালো');

      expect(controller.messages.last.text, 'ফেইক উত্তর');
      expect(controller.messages.last.isUser, isFalse);
    });

    test('override না করলে ভিন্ন getIt<ChatController>() কল একই MarcusChatService শেয়ার করে', () {
      final c1 = getIt<ChatController>();
      final c2 = getIt<ChatController>();

      
      expect(identical(c1, c2), isFalse);
      expect(
        identical(getIt<MarcusChatService>(), getIt<MarcusChatService>()),
        isTrue,
      );
    });
  });

    group('ChatController behavior', () {
    test('outOfContextCount শুরুতে ০, trim হওয়ার পর বাড়ে', () async {
      final fake = FakeChatCompletionService(replyToReturn: 'উত্তর');
      final service = MarcusChatService(
        chatService: fake,
        conversationManager: ConversationManager(maxTurns: 1), 
      );
      final controller = ChatController(service: service);

      expect(controller.outOfContextCount, 0);

      await controller.send('প্রশ্ন ১');
      expect(controller.outOfContextCount, 0);

      await controller.send('প্রশ্ন ২'); 
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
        expect(controller.outOfContextCount, 0); 
        controller.dispose();
      },
    );
  });
}