import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PhilosopherAvatar extends StatefulWidget {
  final double size;
  final bool showOnlineIndicator;

  const PhilosopherAvatar({
    super.key,
    this.size = 44,
    this.showOnlineIndicator = true,
  });

  @override
  State<PhilosopherAvatar> createState() => _PhilosopherAvatarState();
}

class _PhilosopherAvatarState extends State<PhilosopherAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1.5),
              image: const DecorationImage(
                image: AssetImage('assets/images/marcus_aurelius.jpg'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          if (widget.showOnlineIndicator)
            Positioned(
              right: -1,
              bottom: -1,
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.obsidian,
                      border: Border.all(color: AppColors.obsidian, width: 2.5),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: _pulseAnim.value),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha: _pulseAnim.value * 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
