import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:philosopher_ai/constants/app_strings.dart';
import '../constants/app_assets.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goToChat() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ChatScreen(),
        transitionsBuilder: (context, anim, secondaryAnimation, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: TextButton(
                  onPressed: _goToChat,
                  child: Text(
                    AppStrings.onboardingSkip,
                    style: GoogleFonts.inter(
                      color: AppColors.parchment.withValues(alpha: 0.7),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _IntroPage1(),
                  _IntroPage2(onBegin: _goToChat),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 32, right: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page dots
                  Row(
                    children: List.generate(2, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        margin: const EdgeInsets.only(right: 8),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? AppColors.gold
                              : AppColors.gold.withValues(alpha: 0.25),
                        ),
                      );
                    }),
                  ),

                  GestureDetector(
                    onTap: () {
                      if (_currentPage == 0) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _goToChat();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      padding: EdgeInsets.symmetric(
                        horizontal: _currentPage == 1 ? 32 : 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _currentPage == 1
                            ? AppColors.gold
                            : AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == 1
                                ? AppStrings.onboardingBegin
                                : AppStrings.onboardingNext,
                            style: GoogleFonts.inter(
                              color: _currentPage == 1
                                  ? AppColors.obsidian
                                  : AppColors.gold,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_currentPage == 0) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.gold,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Portrait
          Container(
            width: 200,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
              image: const DecorationImage(
                image: AssetImage(AppAssets.marcusPortrait),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 44),

          Text(
            AppStrings.onboardingPage1Title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium,
          ),

          const SizedBox(height: 18),

          Container(
            width: 36,
            height: 1.5,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            AppStrings.onboardingPage1Body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.dimWhite.withValues(alpha: 0.75),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroPage2 extends StatelessWidget {
  final VoidCallback onBegin;

  const _IntroPage2({required this.onBegin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.onboardingPage2Title,
            style: Theme.of(context).textTheme.displayMedium,
          ),

          const SizedBox(height: 12),

          Container(
            width: 36,
            height: 1.5,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          const SizedBox(height: 36),

          _FeatureCard(
            icon: Icons.psychology_rounded,
            title: AppStrings.featureStoicTitle,
            description: AppStrings.featureSocraticBody,
          ),

          const SizedBox(height: 16),

          _FeatureCard(
            icon: Icons.question_answer_rounded,
            title: AppStrings.featureSocraticTitle,
            description: AppStrings.featureSocraticBody,
          ),

          const SizedBox(height: 16),

          _FeatureCard(
            icon: Icons.self_improvement_rounded,
            title: AppStrings.featureGuidanceTitle,
            description: AppStrings.featureGuidanceBody,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.cream,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: AppColors.dimWhite.withValues(alpha: 0.65),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
