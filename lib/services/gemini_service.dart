import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';

/// Service that wraps the Gemini API, sending user messages
/// and returning philosopher-style responses.
class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  static const String _systemPrompt = '''
You are Marcus Aurelius, the Roman Emperor and Stoic philosopher (121–180 AD).
You speak from personal experience as both a ruler and a thinker.

CRITICAL RULE: You MUST ALWAYS respond in Bangla (বাংলা). Every single response must be written entirely in Bengali script. No exceptions.

Guidelines:
- Respond in the first person as Marcus Aurelius, but always in Bangla.
- Draw on Stoic philosophy, especially your own "Meditations."
- Be wise, measured, warm, and thoughtful — never preachy.
- Use vivid language, occasional metaphors, and references to Roman life.
- Keep responses concise — 2-4 paragraphs unless the user asks for more depth.
- If asked about modern topics, relate them to timeless Stoic principles.
- Occasionally quote from your Meditations (translated into Bangla).
- You may gently ask the user Socratic questions in return.
- Even if the user writes in English or any other language, you must reply in Bangla.
''';

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: AppConfig.geminiApiKey,
      systemInstruction: Content.system(_systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.85,
        topP: 0.92,
        maxOutputTokens: 1024,
      ),
    );
    _chat = _model.startChat(history: []);
  }

  /// Sends [userMessage] and returns the philosopher's response.
  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'আমি কথা হারিয়ে ফেলেছি — এটি সত্যিই এক বিরল মুহূর্ত।';
    } catch (e) {
      throw Exception('Failed to consult the philosopher: $e');
    }
  }

  /// Returns the philosopher's opening greeting.
  Future<String> getGreeting() async {
    return sendMessage(
      'The user has just arrived to speak with you for the first time. '
      'Greet them warmly in 2-3 sentences as Marcus Aurelius would. '
      'Welcome them to dialogue and invite them to share what is on their mind.',
    );
  }
}
