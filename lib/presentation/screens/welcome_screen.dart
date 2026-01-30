// File: lib/presentation/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Animated splash/welcome screen
/// Auto-navigates to GetStartedScreen after splash animation
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
    // Navigate after splash animation completes
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/get-started');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle gradient background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      AppTheme.primary.withOpacity(isDark ? 0.04 : 0.06),
                    ],
                  ),
                ),
              ),
            ),

            // Background glow circle
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90),
                child:
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(
                          isDark ? 0.06 : 0.10,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    ),
              ),
            ),

            // Main content - Logo and title
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo container
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
                                : context.borderColor,
                          ),
                          boxShadow: isDark
                              ? []
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
                              child: Icon(
                                Icons.spa,
                                size: 48,
                                color: AppTheme.primary,
                              ),
                            ),
                            // Status dot
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 2,
                                    color: isDark
                                        ? AppTheme.bgDark
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 18),

                  // App name
                  Text(
                        'Homeocare',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: context.textPrimary,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                        'Reception Assistant',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          color: context.textSecondary,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),

            // Bottom powered by text
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
                    color: AppTheme.textSecondaryLight.withOpacity(
                      isDark ? 0.75 : 0.85,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              ),
            ),

            // Loading indicator
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primary.withOpacity(0.6),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
