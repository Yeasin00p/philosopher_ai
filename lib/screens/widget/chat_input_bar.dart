import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.isSending,
    required this.onSend,
  });

  final bool isSending;

  final ValueChanged<String> onSend;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  final _hasText = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      _hasText.value = _textController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _hasText.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty || widget.isSending) return;
    _textController.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.navy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: GoogleFonts.inter(color: AppColors.cream, fontSize: 14.5),
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Speak your mind...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.parchment.withValues(alpha: 0.45),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder<bool>(
            valueListenable: _hasText,
            builder: (context, hasText, _) {
              final enabled = hasText && !widget.isSending;
              return GestureDetector(
                onTap: enabled ? _submit : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled
                        ? AppColors.gold
                        : AppColors.gold.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.35),
                    ),
                    boxShadow: [
                      if (enabled)
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: enabled
                        ? AppColors.obsidian
                        : AppColors.gold.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
