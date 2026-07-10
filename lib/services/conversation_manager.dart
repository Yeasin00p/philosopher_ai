import 'character_memory.dart';

/// Owns the raw `{role, content}` history sent to the model. Separate from
/// the UI-facing `ChatMessage` list (chat_screen owns that) and separate
/// from the HTTP layer (GroqService owns that) — this class only knows
/// about turns, trimming, and memory bookkeeping.
class ConversationManager {
  ConversationManager({int maxTurns = 12}) : _maxMessages = maxTurns * 2;

  final int _maxMessages;
  final List<Map<String, String>> _history = [];

  /// Heuristic facts about the user, derived from their messages.
  final CharacterMemory memory = CharacterMemory();

  List<Map<String, String>> get history => List.unmodifiable(_history);

  void addUserMessage(String text) {
    _history.add({'role': 'user', 'content': text});
    memory.observeUserMessage(text);
    _trim();
  }

  void addAssistantMessage(String text) {
    _history.add({'role': 'assistant', 'content': text});
    _trim();
  }

  /// Called when a request fails after retries, so a user turn never sits
  /// in history without a reply (which would confuse the next request).
  void removeLastUserMessageIfPresent() {
    if (_history.isNotEmpty && _history.last['role'] == 'user') {
      _history.removeLast();
    }
  }

  void _trim() {
    if (_history.length > _maxMessages) {
      _history.removeRange(0, _history.length - _maxMessages);
    }
  }

  void clear() {
    _history.clear();
    memory.clear();
  }
}