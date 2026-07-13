
abstract class ChatCompletionService {
  Future<String> complete(
    List<Map<String, String>> messages, {
    double temperature,
    double topP,
    int maxTokens,
  });

  void dispose();
}