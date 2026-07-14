import 'package:get_it/get_it.dart';

import '../controllers/chat_controller.dart';
import '../services/chat_completion_service.dart';
import '../services/conversation_manager.dart';
import '../services/groq_service.dart';
import '../services/prompt_builder.dart';
import '../services/marcus_chat_service.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerLazySingleton<ChatCompletionService>(() => GroqService());

  getIt.registerLazySingleton<ConversationManager>(() => ConversationManager());
  getIt.registerLazySingleton<PromptBuilder>(() => const PromptBuilder());

  getIt.registerLazySingleton<MarcusChatService>(
    () => MarcusChatService(
      chatService: getIt<ChatCompletionService>(),
      conversationManager: getIt<ConversationManager>(),
      promptBuilder: getIt<PromptBuilder>(),
    ),
  );

  getIt.registerFactory<ChatController>(
    () => ChatController(service: getIt<MarcusChatService>()),
  );
}

Future<void> resetServiceLocator() async {
  await getIt.reset();
}
