// File: lib/screens/get_started_screen.dart
import 'package:flutter/material.dart';

import 'login_signup_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  static const routeName = '/get-started';

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13EC80);
    const bgLight = Color(0xFFF6F8F7);
    const bgDark = Color(0xFF102219);
    const surfaceDark = Color(0xFF1A3326);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            // Progress indicators (3 steps, step 3 active)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bar(primary.withOpacity(isDark ? 0.30 : 0.40)),
                const SizedBox(width: 10),
                _bar(primary.withOpacity(isDark ? 0.30 : 0.40)),
                const SizedBox(width: 10),
                _bar(primary, glow: true),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration placeholder (clean + modern)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 360),
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: isDark ? surfaceDark : Colors.white,
                        boxShadow: isDark
                            ? const []
                            : [
                                BoxShadow(
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                  color: Colors.black.withOpacity(0.08),
                                ),
                              ],
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.10)
                              : const Color(0xFFE9EFEC),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      primary.withOpacity(isDark ? 0.10 : 0.14),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: Icon(
                              Icons.assignment_rounded,
                              size: 72,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Track Consultations &\nPrescriptions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF0D1B14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Manage patient consultations and issue digital prescriptions instantly. '
                      'Keep every detail organized in one secure place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: const Color(0xFF0D1B14),
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(LoginSignupScreen.routeName);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(LoginSignupScreen.routeName);
                    },
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : Colors.black45,
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

  static Widget _bar(Color color, {bool glow = false}) {
    return Container(
      width: 34,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
        boxShadow: glow
            ? [
                BoxShadow(
                  blurRadius: 14,
                  color: color.withOpacity(0.55),
                  offset: const Offset(0, 2),
                ),
              ]
            : const [],
      ),
    );
  }
}
