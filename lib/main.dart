import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

void main() {
  runApp(const TarElCharApp());
}

class TarElCharApp extends StatelessWidget {
  const TarElCharApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tar el Char',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: const Color(0xFFB8860B),
        fontFamily: 'serif',
      ),
      home: const OnboardingScreen(),
    );
  }
}
