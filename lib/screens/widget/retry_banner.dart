import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class RetryBanner extends StatelessWidget {
  const RetryBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.navy,
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppColors.gold.withValues(alpha: 0.8),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'বার্তাটি পাঠানো যায়নি।',
              style: GoogleFonts.inter(
                color: AppColors.parchment.withValues(alpha: 0.75),
                fontSize: 12.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'আবার চেষ্টা করুন',
              style: GoogleFonts.inter(
                color: AppColors.gold,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
