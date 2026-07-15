import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/services/conversation_manager.dart';

void main() {
  group('ConversationManager', () {
    test('addUserMessage appends a user-role entry', () {
      final manager = ConversationManager();

      manager.addUserMessage('হ্যালো');

      expect(manager.history.length, 1);
      expect(manager.history.first['role'], 'user');
      expect(manager.history.first['content'], 'হ্যালো');
    });

    test('addAssistantMessage appends an assistant-role entry', () {
      final manager = ConversationManager();

      manager.addUserMessage('প্রশ্ন');
      manager.addAssistantMessage('উত্তর');

      expect(manager.history.length, 2);
      expect(manager.history.last['role'], 'assistant');
      expect(manager.history.last['content'], 'উত্তর');
    });

    test('addUserMessage feeds CharacterMemory.observeUserMessage', () {
      final manager = ConversationManager();

      manager.addUserMessage('আমার নাম আরিফ');

      expect(manager.memory.userName, 'আরিফ');
    });

    test('history exposes an unmodifiable list', () {
      final manager = ConversationManager();
      manager.addUserMessage('হ্যালো');

      expect(() => manager.history.add({'role': 'user', 'content': 'x'}),
          throwsUnsupportedError);
    });

    group('trimming', () {
      test('keeps history at or below maxTurns * 2 messages', () {
        // maxTurns: 2 -> _maxMessages = 4
        final manager = ConversationManager(maxTurns: 2);

        for (var i = 0; i < 5; i++) {
          manager.addUserMessage('user-$i');
          manager.addAssistantMessage('assistant-$i');
        }

        // 5 user + 5 assistant = 10 raw additions, capped at 4.
        expect(manager.history.length, 4);
      });

      test('trims from the oldest messages (FIFO)', () {
        final manager = ConversationManager(maxTurns: 1); // _maxMessages = 2

        manager.addUserMessage('turn-1-user');
        manager.addAssistantMessage('turn-1-assistant');
        manager.addUserMessage('turn-2-user');
        manager.addAssistantMessage('turn-2-assistant');

        expect(manager.history.length, 2);
        expect(manager.history.first['content'], 'turn-2-user');
        expect(manager.history.last['content'], 'turn-2-assistant');
      });

      test('does not trim when under the cap', () {
        final manager = ConversationManager(maxTurns: 12); // _maxMessages = 24

        manager.addUserMessage('হ্যালো');
        manager.addAssistantMessage('স্বাগতম');

        expect(manager.history.length, 2);
      });
    });

    group('removeLastUserMessageIfPresent', () {
      test('removes the last entry when it is a user message', () {
        final manager = ConversationManager();
        manager.addUserMessage('প্রশ্ন যেটার জবাব আসেনি');

        manager.removeLastUserMessageIfPresent();

        expect(manager.history, isEmpty);
      });

      test('is a no-op when the last entry is an assistant message', () {
        final manager = ConversationManager();
        manager.addUserMessage('প্রশ্ন');
        manager.addAssistantMessage('উত্তর');

        manager.removeLastUserMessageIfPresent();

        expect(manager.history.length, 2);
        expect(manager.history.last['role'], 'assistant');
      });

      test('is a no-op when history is empty', () {
        final manager = ConversationManager();

        expect(() => manager.removeLastUserMessageIfPresent(), returnsNormally);
        expect(manager.history, isEmpty);
      });
    });

    group('clear', () {
      test('empties history and resets memory', () {
        final manager = ConversationManager();
        manager.addUserMessage('আমার নাম আরিফ, মন খারাপ লাগছে');
        manager.addAssistantMessage('উত্তর');

        manager.clear();

        expect(manager.history, isEmpty);
        expect(manager.memory.userName, isNull);
        expect(manager.memory.dominantMood, isNull);
      });
    });
  });
}