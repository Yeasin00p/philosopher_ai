import 'package:flutter/foundation.dart';
import '../../models/chat_message.dart';
import '../../services/marcus_chat_service.dart';
import '../../services/marcus_prompt.dart';

class ChatController extends ChangeNotifier {
  ChatController({MarcusChatService? service})
    : _service = service ?? MarcusChatService();

  final MarcusChatService _service;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  String? _lastFailedText;
  bool get hasFailedMessage => _lastFailedText != null;

  Future<void> loadGreeting() async {
    _isTyping = true;
    notifyListeners();

    final greeting = await _service.getGreeting();

    _messages.add(
      ChatMessage(text: greeting, isUser: false, timestamp: DateTime.now()),
    );
    _isLoading = false;
    _isTyping = false;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isTyping) return;

    _lastFailedText = null;
    _messages.add(
      ChatMessage(text: trimmed, isUser: true, timestamp: DateTime.now()),
    );
    _isTyping = true;
    notifyListeners();

    try {
      final reply = await _service.sendMessage(trimmed);
      _messages.add(
        ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()),
      );
    } catch (e) {
      _lastFailedText = trimmed;
      _messages.add(
        ChatMessage(
          text: _friendlyError(e),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  void retryLastFailed() {
    final text = _lastFailedText;
    if (text != null) send(text);
  }

  String _friendlyError(Object e) {
    if (e is NetworkException || e is ApiException) return e.toString();
    return MarcusPrompt.genericFailure;
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
