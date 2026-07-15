import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/chat_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          duration: const Duration(milliseconds: 800),
        ),
      ),
      GoRoute(
        path: AppRoutes.chat,
        pageBuilder: (context, state) => _fadePage(
          key: state.pageKey,
          child: const ChatScreen(),
          duration: const Duration(milliseconds: 600),
        ),
      ),
    ],
  );

  static CustomTransitionPage _fadePage({
    required LocalKey key,
    required Widget child,
    required Duration duration,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}