import 'character_memory.dart';
import 'marcus_prompt.dart';

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
