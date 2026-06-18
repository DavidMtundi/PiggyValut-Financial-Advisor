import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piggy_flutter/blocs/auth/auth.dart';
import 'package:piggy_flutter/theme/piggy_app_theme.dart';
import 'package:piggy_flutter/utils/uidata.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(UIData.firstAccess, false);
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  final _pages = const [
    _OnboardingPageData(
      title: 'Track together',
      subtitle:
          'Manage family accounts, expenses, and savings in one beautiful place.',
      icon: Icons.family_restroom_rounded,
      accent: Color(0xFF54D3C2),
    ),
    _OnboardingPageData(
      title: 'Smart insights',
      subtitle:
          'See where your money goes with clear reports and monthly summaries.',
      icon: Icons.insights_rounded,
      accent: Color(0xFF5B8DEF),
    ),
    _OnboardingPageData(
      title: 'Stay in control',
      subtitle:
          'Add transactions quickly, set categories, and keep everyone aligned.',
      icon: Icons.savings_rounded,
      accent: Color(0xFF7C6CF2),
    ),
  ];

  void _finish() {
    markOnboardingComplete();
    context.read<AuthBloc>().add(AppStarted());
  }

  void _next() {
    if (_pageIndex == _pages.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = PiggyAppTheme.buildLightTheme();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('onboarding_skip_button'),
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                page.accent.withValues(alpha: 0.18),
                                page.accent.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            page.icon,
                            size: 96,
                            color: page.accent,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontFamily: 'WorkSans',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: PiggyAppTheme.lightText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final active = index == _pageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  key: Key(
                    _pageIndex == _pages.length - 1
                        ? 'onboarding_done_button'
                        : 'onboarding_next_button',
                  ),
                  onPressed: _next,
                  child: Text(
                    _pageIndex == _pages.length - 1 ? 'Get Started' : 'Next',
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

class _OnboardingPageData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}
