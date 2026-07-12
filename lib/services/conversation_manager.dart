import 'character_memory.dart';

class ConversationManager {
  ConversationManager({int maxTurns = 12}) : _maxMessages = maxTurns * 2;

  final int _maxMessages;
  final List<Map<String, String>> _history = [];
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
