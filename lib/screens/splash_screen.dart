import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

/// Cinematic splash screen with animated logo and tagline.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _fadeIn;
  late Animation<double> _taglineFade;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.15, end: 0.4).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, anim, secondaryAnimation, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _glowController]),
        builder: (context, _) {
          return Stack(
            children: [
              // Radial gold glow
              Center(
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withValues(alpha: _glowAnim.value * 0.35),
                        AppColors.gold.withValues(alpha: _glowAnim.value * 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, 15 * (1 - _fadeIn.value)),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: AppColors.gold.withValues(alpha: _fadeIn.value),
                            size: 36,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App name
                    Opacity(
                      opacity: _fadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, 12 * (1 - _fadeIn.value)),
                        child: Text(
                          'MARCUS\nAURELIUS',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            color: AppColors.cream,
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 6,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Divider line
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Container(
                        width: 50,
                        height: 1,
                        color: AppColors.gold.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tagline
                    Opacity(
                      opacity: _taglineFade.value,
                      child: Text(
                        'WISDOM THROUGH DIALOGUE',
                        style: GoogleFonts.inter(
                          color: AppColors.parchment,
                          fontSize: 11,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
