// File: lib/presentation/screens/get_started_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/ui_components.dart';

/// Onboarding screens with feature highlights
class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  static const routeName = '/get-started';

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.people_alt_rounded,
      title: 'Manage Patients\nEfficiently',
      description:
          'Keep track of all your patients with comprehensive profiles, medical history, and contact information in one place.',
    ),
    _OnboardingPage(
      icon: Icons.calendar_month_rounded,
      title: 'Schedule\nAppointments',
      description:
          'Organize your clinic schedule with easy appointment booking, reminders, and follow-up tracking.',
    ),
    _OnboardingPage(
      icon: Icons.assignment_rounded,
      title: 'Track Consultations &\nPrescriptions',
      description:
          'Manage patient consultations and issue digital prescriptions instantly. Keep every detail organized in one secure place.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),

            // Page indicator
            PageIndicator(
              count: _pages.length,
              currentIndex: _currentPage,
            ).animate().fadeIn(duration: 300.ms),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page, isDark);
                },
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    icon: Icons.arrow_forward,
                    isStadium: true,
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: 300.ms,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _goToLogin();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.textTertiary,
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

  Widget _buildPage(_OnboardingPage page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration container
          Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 360),
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: context.cardColor,
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ],
                  border: Border.all(color: context.borderColor),
                ),
                child: Stack(
                  children: [
                    // Gradient overlay
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
                                AppTheme.primary.withOpacity(
                                  isDark ? 0.10 : 0.14,
                                ),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(page.icon, size: 72, color: AppTheme.primary),
                    ),
                  ],
                ),
              )
              .animate(key: ValueKey(page.icon))
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOut,
              ),

          const SizedBox(height: 32),

          // Title
          Text(
                page.title,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(height: 1.15),
              )
              .animate(key: ValueKey('${page.icon}_title'))
              .fadeIn(delay: 100.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          // Description
          Text(
                page.description,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.textTertiary,
                  height: 1.5,
                ),
              )
              .animate(key: ValueKey('${page.icon}_desc'))
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
