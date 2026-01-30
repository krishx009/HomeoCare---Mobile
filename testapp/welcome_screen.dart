// File: lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';

import 'get_started_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  static const routeName = '/welcome';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Splash delay then move forward
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(GetStartedScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    const bgLight = Color(0xFFF6F8F7);
    const bgDark = Color(0xFF102219);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle gradient + glow
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      primary.withOpacity(isDark ? 0.04 : 0.06),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(isDark ? 0.06 : 0.10),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo card
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.10)
                            : const Color(0xFFEFF3F1),
                      ),
                      boxShadow: isDark
                          ? const []
                          : [
                              BoxShadow(
                                blurRadius: 18,
                                spreadRadius: 0,
                                offset: const Offset(0, 6),
                                color: Colors.black.withOpacity(0.06),
                              ),
                            ],
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(Icons.spa, size: 48, color: primary),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: isDark
                                    ? const Color(0xFF1A2E24)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Homeocare',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: isDark ? Colors.white : const Color(0xFF0D1B14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reception Assistant',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Text(
                  'POWERED BY HOMECARE SYSTEMS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                    color: const Color(
                      0xFF4C9A73,
                    ).withOpacity(isDark ? 0.75 : 0.85),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
