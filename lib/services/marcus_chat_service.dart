import 'package:philosopher_ai/constants/app_strings.dart';

import 'character_memory.dart';
import 'chat_completion_service.dart';
import 'conversation_manager.dart';
import 'groq_service.dart';
import 'marcus_prompt.dart';
import 'prompt_builder.dart';
import 'user_facing_exception.dart';

class MarcusChatService {
  MarcusChatService({
    ChatCompletionService? chatService,
    GroqService? groqService,
    ConversationManager? conversationManager,
    PromptBuilder? promptBuilder,
  }) : _chatService = chatService ?? GroqService(),
       _conversation = conversationManager ?? ConversationManager(),
       _promptBuilder = promptBuilder ?? const PromptBuilder();

  final ChatCompletionService _chatService;
  final ConversationManager _conversation;
  final PromptBuilder _promptBuilder;

  List<Map<String, String>> get history => _conversation.history;
  CharacterMemory get memory => _conversation.memory;

  int get contextDroppedCount => _conversation.droppedCount;

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
      throw ApiException(AppStrings.emptyMessageError);
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
      final reply = await _chatService.complete(messages);
      _conversation.addAssistantMessage(reply);
      return reply;
    } catch (e) {
      _conversation.removeLastUserMessageIfPresent();

      if (e is UserFacingException) rethrow;
      throw ApiException(MarcusPrompt.genericFailure);
    }
  }

  void clearHistory() => _conversation.clear();

  void dispose() => _chatService.dispose();
}
