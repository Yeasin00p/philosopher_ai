import 'character_memory.dart';
import 'marcus_prompt.dart';

/// Assembles the final `messages` array sent to the API: base persona +
/// a short character-memory brief + the raw turn history. Kept separate
/// so prompt structure can change without touching the API client or
/// history management.
class PromptBuilder {
  const PromptBuilder();

  List<Map<String, String>> buildMessages({
    required List<Map<String, String>> history,
    required CharacterMemory memory,
  }) {
    final systemContent = StringBuffer(MarcusPrompt.system);

    final brief = memory.buildBrief();
    if (brief.isNotEmpty) {
      systemContent
        ..writeln()
        ..writeln('--- প্রসঙ্গ (কথোপকথন থেকে সংগৃহীত) ---')
        ..writeln(brief);
    }

    return [
      {'role': 'system', 'content': systemContent.toString()},
      ...history,
    ];
  }
}