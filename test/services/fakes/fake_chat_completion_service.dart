import 'package:philosopher_ai/services/chat_completion_service.dart';

class FakeChatCompletionService implements ChatCompletionService {
  FakeChatCompletionService({this.replyToReturn = 'ফেক উত্তর', this.shouldThrow});

  String replyToReturn;
  Exception? shouldThrow;

  int callCount = 0;
  List<Map<String, String>>? lastMessages;
  bool disposed = false;

  @override
  Future<String> complete(
    List<Map<String, String>> messages, {
    double temperature = 1.1,
    double topP = 0.92,
    int maxTokens = 1024,
  }) async {
    callCount++;
    lastMessages = messages;
    if (shouldThrow != null) throw shouldThrow!;
    return replyToReturn;
  }

  @override
  void dispose() => disposed = true;
}