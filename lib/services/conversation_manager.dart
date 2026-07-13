import 'character_memory.dart';

class ConversationManager {
  ConversationManager({int maxTurns = 12}) : _maxMessages = maxTurns * 2;

  final int _maxMessages;
  final List<Map<String, String>> _history = [];

  final CharacterMemory memory = CharacterMemory();

  int _droppedCount = 0;
  int get droppedCount => _droppedCount;

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
      final excess = _history.length - _maxMessages;
      _history.removeRange(0, excess);
      _droppedCount += excess;
    }
  }

  void clear() {
    _history.clear();
    memory.clear();
    _droppedCount = 0;
  }
}
