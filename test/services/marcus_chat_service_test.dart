import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/services/groq_service.dart';
import 'package:philosopher_ai/services/marcus_chat_service.dart';

import 'fakes/fake_chat_completion_service.dart';

void main() {
  late FakeChatCompletionService fakeService;
  late MarcusChatService chatService;

  setUp(() {
    fakeService = FakeChatCompletionService();
    chatService = MarcusChatService(chatService: fakeService);
  });

  group('sendMessage', () {
    test('সফল হলে reply রিটার্ন করে এবং history তে যোগ হয়', () async {
      fakeService.replyToReturn = 'জ্ঞানের কথা';

      final reply = await chatService.sendMessage('আজ আমার মন খারাপ');

      expect(reply, 'জ্ঞানের কথা');
      expect(chatService.history.length, 2); // user + assistant
      expect(chatService.history.first['role'], 'user');
      expect(chatService.history.last['role'], 'assistant');
    });

    test('খালি বার্তা পাঠালে ApiException থ্রো করে', () {
      expect(
        () => chatService.sendMessage('   '),
        throwsA(isA<ApiException>()),
      );
    });

    test('ব্যর্থ হলে user message history থেকে সরিয়ে দেয়', () async {
      fakeService.shouldThrow = NetworkException('নেটওয়ার্ক ত্রুটি');

      await expectLater(
        () => chatService.sendMessage('হ্যালো'),
        throwsA(isA<NetworkException>()),
      );

      // আগের মেসেজটা dangling থাকা উচিত না
      expect(chatService.history, isEmpty);
    });

    test('চ্যাট সার্ভিসে সঠিক messages পাঠানো হয় (system + history)', () async {
      await chatService.sendMessage('স্টোয়িক দর্শন কী?');

      final sentMessages = fakeService.lastMessages!;
      expect(sentMessages.first['role'], 'system');
      expect(sentMessages.last['content'], 'স্টোয়িক দর্শন কী?');
    });
  });

  group('getGreeting', () {
    test('সফল হলে API থেকে greeting রিটার্ন করে', () async {
      fakeService.replyToReturn = 'স্বাগতম, বন্ধু।';

      final greeting = await chatService.getGreeting();

      expect(greeting, 'স্বাগতম, বন্ধু।');
    });

    test('ব্যর্থ হলে fallback greeting রিটার্ন করে, exception ছড়ায় না', () async {
      fakeService.shouldThrow = NetworkException('টাইমআউট');

      final greeting = await chatService.getGreeting();

      expect(greeting, isNotEmpty); // MarcusPrompt.fallbackGreeting
    });
  });

  group('clearHistory ও dispose', () {
    test('clearHistory ডাকলে history খালি হয়', () async {
      await chatService.sendMessage('একটা কথা');
      expect(chatService.history, isNotEmpty);

      chatService.clearHistory();

      expect(chatService.history, isEmpty);
    });

    test('dispose করলে underlying chatService ও dispose হয়', () {
      chatService.dispose();
      expect(fakeService.disposed, isTrue);
    });
  });
}