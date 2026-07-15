import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/services/character_memory.dart';

void main() {
  group('CharacterMemory mood windowing', () {
    test('dominant mood follows a short streak before the window fills', () {
      final memory = CharacterMemory(moodWindowSize: 4);

      memory.observeUserMessage('আমার খুব দুঃখ লাগছে আজ');
      memory.observeUserMessage('মন খারাপ, একা লাগছে');

      expect(memory.dominantMood, 'দুঃখ');
    });

    test('older mood is displaced once enough newer messages arrive', () {
      final memory = CharacterMemory(moodWindowSize: 4);

      memory.observeUserMessage('আমার খুব দুঃখ লাগছে আজ');
      memory.observeUserMessage('মন খারাপ, একা লাগছে');

      memory.observeUserMessage('আজ আমি খুব খুশি');
      memory.observeUserMessage('সত্যিই আনন্দ লাগছে');
      memory.observeUserMessage('ভালো লাগছে এখন');

      expect(memory.dominantMood, 'আনন্দ');
    });

    test('buildBrief reflects the shifted mood in Bangla', () {
      final memory = CharacterMemory(moodWindowSize: 3);

      memory.observeUserMessage('আমার নাম রাহাত');
      memory.observeUserMessage('খুব রাগ হচ্ছে');
      memory.observeUserMessage('এখন খুশি লাগছে');
      memory.observeUserMessage('আনন্দ লাগছে আজ');

      final brief = memory.buildBrief();
      expect(brief, contains('ব্যবহারকারীর নাম: রাহাত'));
      expect(brief, contains('প্রধান অনুভূতির ধরন: আনন্দ'));
    });
    test('clear resets both name and the mood window', () {
      final memory = CharacterMemory();

      memory.observeUserMessage('আমার নাম সাদিয়া');
      memory.observeUserMessage('আমার রাগ হচ্ছে');

      memory.clear();

      expect(memory.userName, isNull);
      expect(memory.dominantMood, isNull);
    });

    test('a message with no keyword match does not affect dominant mood', () {
      final memory = CharacterMemory(moodWindowSize: 3);

      memory.observeUserMessage('আজ আমি খুশি');
      memory.observeUserMessage('আজকের আবহাওয়া কেমন?');

      expect(memory.dominantMood, 'আনন্দ');
    });
  });
}
