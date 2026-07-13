import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:philosopher_ai/widgets/philosopher_avatar.dart';

import '../../theme/app_theme.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key, required this.fadeAnimation});

  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          bottom: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.navy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const PhilosopherAvatar(size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Marcus Aurelius',
                    style: GoogleFonts.playfairDisplay(
                      color: AppColors.cream,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Ready to converse',
                        style: GoogleFonts.inter(
                          color: AppColors.parchment.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.more_vert_rounded,
                color: AppColors.gold.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
