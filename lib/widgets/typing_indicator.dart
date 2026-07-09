import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated three-dot "thinking" indicator styled as the philosopher pondering.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.2;
        final t = (_controller.value - delay).clamp(0.0, 1.0);
        final bounce = (t < 0.5)
            ? Curves.easeOut.transform(t * 2)
            : Curves.easeIn.transform((1 - t) * 2);
        return Transform.translate(
          offset: Offset(0, -4 * bounce),
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.4 + 0.5 * bounce),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      margin: const EdgeInsets.only(left: 12, right: 80, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.philosopherBubble,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
          bottomLeft: Radius.circular(6),
        ),
        border: Border.all(
          color: AppColors.philosopherBubbleBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(0),
          const SizedBox(width: 5),
          _buildDot(1),
          const SizedBox(width: 5),
          _buildDot(2),
        ],
      ),
    );
  }
}
