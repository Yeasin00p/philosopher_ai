import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'di/service_locator.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.obsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const PhilosopherApp());
}

class PhilosopherApp extends StatelessWidget {
  const PhilosopherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marcus Aurelius — AI Philosopher',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SplashScreen(),
    );
  }
}
