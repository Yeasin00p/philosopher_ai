import 'package:flutter/material.dart';
import 'package:philosopher_ai/di/service_locator.dart';

import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import 'widget/chat_controller.dart';
import 'widget/chat_header.dart';
import 'widget/chat_input_bar.dart';
import 'widget/chat_loading_state.dart';
import 'widget/context_notice.dart';
import 'widget/retry_banner.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  static const _headerFadeDuration = Duration(milliseconds: 600);
  static const _scrollDuration = Duration(milliseconds: 350);

  late final ChatController _chat;
  late final AnimationController _headerFade;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chat = getIt<ChatController>()..addListener(_scrollToBottom);
    _headerFade = AnimationController(
      vsync: this,
      duration: _headerFadeDuration,
    )..forward();
    _chat.loadGreeting();
  }

  @override
  void dispose() {
    _chat.removeListener(_scrollToBottom);
    _chat.dispose();
    _headerFade.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: _scrollDuration,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: Column(
        children: [
          ChatHeader(fadeAnimation: _headerFade),
          Container(height: 1, color: AppColors.divider),
          Expanded(
            child: ListenableBuilder(
              listenable: _chat,
              builder: (context, _) {
                if (_chat.isLoading) return const ChatLoadingState();

                final messages = _chat.messages;
                final showContextNotice = _chat.outOfContextCount > 0;
                final itemCount =
                    (showContextNotice ? 1 : 0) +
                    messages.length +
                    (_chat.isTyping ? 1 : 0);

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 20, bottom: 8),
                  itemCount: itemCount,
                  itemBuilder: (context, i) {
                    var index = i;

                    if (showContextNotice) {
                      if (index == 0) return const ContextNotice();
                      index -= 1;
                    }

                    if (index < messages.length) {
                      final message = messages[index];
                      return MessageBubble(
                        key: ValueKey(message.timestamp.microsecondsSinceEpoch),
                        message: message,
                      );
                    }
                    return const TypingIndicator();
                  },
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: _chat,
            builder: (context, _) => _chat.hasFailedMessage
                ? RetryBanner(onRetry: _chat.retryLastFailed)
                : const SizedBox.shrink(),
          ),
          ListenableBuilder(
            listenable: _chat,
            builder: (context, _) =>
                ChatInputBar(isSending: _chat.isTyping, onSend: _chat.send),
          ),
        ],
      ),
    );
  }
}
