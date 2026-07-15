import 'package:flutter_test/flutter_test.dart';
import 'package:philosopher_ai/services/character_memory.dart';

void main() {
  group('CharacterMemory', () {
    group('name detection', () {
      test('detects name from "আমার নাম X" pattern', () {
        final memory = CharacterMemory();

        memory.observeUserMessage('আমার নাম আরিফ');

        expect(memory.userName, 'আরিফ');
      });

      test('detects name from "আমি X বলছি" pattern', () {
        final memory = CharacterMemory();

        memory.observeUserMessage('আমি সাকিব বলছি');

        expect(memory.userName, 'সাকিব');
      });

      test('does not overwrite a previously detected name', () {
        final memory = CharacterMemory();

        memory.observeUserMessage('আমার নাম আরিফ');
        memory.observeUserMessage('আমার নাম রহিম');

        expect(memory.userName, 'আরিফ');
      });

      test('leaves userName null when no pattern matches', () {
        final memory = CharacterMemory();

        memory.observeUserMessage('আজকে আবহাওয়া কেমন?');

        expect(memory.userName, isNull);
      });
    });

    group('mood detection', () {
      test('detects sadness ("দুঃখ") from keyword match', () {
        final memory = CharacterMemory();

        memory.observeUserMessage('আজ আমার মন খারাপ');

        expect(memory.dominantMood, 'দুঃখ');
      });

      test('detects anxiety ("উদ্বেগ") from keyword match', () {
        final memory = CharacterMemory();

        memory.observeUserMessage('আমি খুব চিন্তিত এই বিষয়ে');

        expect(memory.dominantMood, 'উদ্বেগ');
      });

      test('dominantMood is null when nothing has been observed', () {
        final memory = CharacterMemory();

        expect(memory.dominantMood, isNull);
      });

      test('dominantMood reflects the most frequently signalled mood', () {
        final memory = CharacterMemory();

        memory.observeUserMessage('মন খারাপ লাগছে');
        memory.observeUserMessage('আজ ভীষণ একা লাগছে');
        memory.observeUserMessage('একটু চিন্তিত অবশ্য');

        // দুঃখ signalled twice ("মন খারাপ", "একা"), উদ্বেগ once ("চিন্তিত").
        expect(memory.dominantMood, 'দুঃখ');
      });
    });

    group('buildBrief', () {
      test('returns empty string when nothing is known', () {
        final memory = CharacterMemory();

        expect(memory.buildBrief(), isEmpty);
      });

      test('includes only the name when mood is unknown', () {
        final memory = CharacterMemory();
        memory.observeUserMessage('আমার নাম আরিফ');

        final brief = memory.buildBrief();

        expect(brief, contains('আরিফ'));
        expect(brief, isNot(contains('অনুভূতি')));
      });

      test('includes both name and mood when both are known', () {
        final memory = CharacterMemory();
        memory.observeUserMessage('আমার নাম আরিফ, মন খারাপ লাগছে');

        final brief = memory.buildBrief();

        expect(brief, contains('আরিফ'));
        expect(brief, contains('দুঃখ'));
      });
    });

    group('clear', () {
      test('resets name and mood signals', () {
        final memory = CharacterMemory();
        memory.observeUserMessage('আমার নাম আরিফ, মন খারাপ লাগছে');

        memory.clear();

        expect(memory.userName, isNull);
        expect(memory.dominantMood, isNull);
        expect(memory.buildBrief(), isEmpty);
      });
    });
  });
}