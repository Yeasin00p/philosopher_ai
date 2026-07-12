import 'character_memory.dart';
import 'conversation_manager.dart';
import 'gorq_service.dart';
import 'marcus_prompt.dart';
import 'prompt_builder.dart';

export 'gorq_service.dart' show NetworkException, ApiException;

class MarcusChatService {
  MarcusChatService({
    GroqService? groqService,
    ConversationManager? conversationManager,
    PromptBuilder? promptBuilder,
  }) : _groq = groqService ?? GroqService(),
       _conversation = conversationManager ?? ConversationManager(),
       _promptBuilder = promptBuilder ?? const PromptBuilder();

  final GroqService _groq;
  final ConversationManager _conversation;
  final PromptBuilder _promptBuilder;

  List<Map<String, String>> get history => _conversation.history;
  CharacterMemory get memory => _conversation.memory;

  Future<String> getGreeting() async {
    try {
      return await _requestReply(MarcusPrompt.greetingInstruction);
    } catch (_) {
      return MarcusPrompt.fallbackGreeting;
    }
  }

  Future<String> sendMessage(String userMessage) {
    final trimmed = userMessage.trim();
    if (trimmed.isEmpty) {
      throw ApiException('বার্তা খালি রাখা যাবে না।');
    }
    return _requestReply(trimmed);
  }

  Future<String> _requestReply(String userText) async {
    _conversation.addUserMessage(userText);
    final messages = _promptBuilder.buildMessages(
      history: _conversation.history,
      memory: _conversation.memory,
    );

    try {
      final reply = await _groq.complete(messages);
      _conversation.addAssistantMessage(reply);
      return reply;
    } catch (e) {
      _conversation.removeLastUserMessageIfPresent();
      rethrow;
    }
  }

  void clearHistory() => _conversation.clear();

  void dispose() => _groq.dispose();
}
