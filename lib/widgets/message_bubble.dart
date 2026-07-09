import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

/// A single chat bubble — styled differently for user vs philosopher.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final time = _formatTime(message.timestamp);

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 60 : 12,
        right: isUser ? 12 : 60,
        bottom: 8,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? AppColors.userBubble : AppColors.philosopherBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(6),
                  bottomRight: isUser
                      ? const Radius.circular(6)
                      : const Radius.circular(20),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.userBubbleBorder
                      : AppColors.philosopherBubbleBorder.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? AppColors.gold : AppColors.philosopherBubbleBorder)
                        .withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: isUser
                    ? GoogleFonts.inter(
                        color: AppColors.cream,
                        fontSize: 14.5,
                        height: 1.55,
                      )
                    : GoogleFonts.playfairDisplay(
                        color: AppColors.cream.withValues(alpha: 0.92),
                        fontSize: 14.5,
                        height: 1.65,
                        fontStyle: FontStyle.italic,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                time,
                style: GoogleFonts.inter(
                  color: AppColors.parchment.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}
