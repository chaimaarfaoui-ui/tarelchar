import 'package:flutter/material.dart';
import 'symptom_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '⚗ Tar el Char',
                    style: TextStyle(
                      color: Color(0xFFB8860B),
                      fontSize: 22,
                      letterSpacing: 3,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.auto_stories_outlined,
                      color: Color(0xFFB8860B),
                    ),
                    tooltip: 'Your consultations',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'What ails you today?',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    const Text(
                      '✦',
                      style: TextStyle(color: Color(0xFFB8860B), fontSize: 60),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'The Grimoire Awaits',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Speak your affliction and receive\nancient wisdom and modern guidance',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SymptomScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB8860B),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Consult the Grimoire',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
