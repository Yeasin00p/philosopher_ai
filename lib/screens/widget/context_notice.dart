import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class ContextNotice extends StatelessWidget {
  const ContextNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 32, right: 32, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: AppColors.parchment.withValues(alpha: 0.6),
            size: 14,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'এর আগের অংশ মার্কাস আর মনে রাখছেন না — শুধু সাম্প্রতিক কথোপকথনের ভিত্তিতে উত্তর দিচ্ছেন।',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.parchment.withValues(alpha: 0.6),
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}