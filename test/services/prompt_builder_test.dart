import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/services/character_memory.dart';
import 'package:philosopher_ai/services/marcus_prompt.dart';
import 'package:philosopher_ai/services/prompt_builder.dart';

void main() {
  group('PromptBuilder', () {
    const builder = PromptBuilder();

    test('first message is the system message containing MarcusPrompt.system', () {
      final messages = builder.buildMessages(
        history: const [],
        memory: CharacterMemory(),
      );

      expect(messages.first['role'], 'system');
      expect(messages.first['content'], contains(MarcusPrompt.system));
    });

    test('does not append a context header when memory brief is empty', () {
      final messages = builder.buildMessages(
        history: const [],
        memory: CharacterMemory(),
      );

      // MarcusPrompt.system itself mentions "প্রসঙ্গ" in a style rule, so
      // assert against the specific header PromptBuilder adds rather than
      // the bare word.
      expect(
        messages.first['content'],
        isNot(contains('প্রসঙ্গ (কথোপকথন থেকে সংগৃহীত)')),
      );
    });

    test('appends the memory brief under a context header when present', () {
      final memory = CharacterMemory();
      memory.observeUserMessage('আমার নাম আরিফ, মন খারাপ লাগছে');

      final messages = builder.buildMessages(
        history: const [],
        memory: memory,
      );

      final systemContent = messages.first['content']!;
      expect(systemContent, contains('প্রসঙ্গ (কথোপকথন থেকে সংগৃহীত)'));
      expect(systemContent, contains(memory.buildBrief()));
    });

    test('preserves history order and appends it after the system message', () {
      final history = [
        {'role': 'user', 'content': 'প্রথম প্রশ্ন'},
        {'role': 'assistant', 'content': 'প্রথম উত্তর'},
        {'role': 'user', 'content': 'দ্বিতীয় প্রশ্ন'},
      ];

      final messages = builder.buildMessages(
        history: history,
        memory: CharacterMemory(),
      );

      expect(messages.length, history.length + 1);
      expect(messages.sublist(1), equals(history));
    });

    test('does not mutate the provided history list', () {
      final history = [
        {'role': 'user', 'content': 'হ্যালো'},
      ];

      builder.buildMessages(history: history, memory: CharacterMemory());

      expect(history.length, 1);
      expect(history.first['content'], 'হ্যালো');
    });
  });
}