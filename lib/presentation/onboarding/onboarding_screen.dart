// lib/presentation/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:plot_twist/application/home/home_providers.dart';
import 'package:plot_twist/presentation/core/auth_guard.dart';

import '../core/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  void _onOnboardingComplete(WidgetRef ref) {
    // Save the fact that the user has seen the onboarding
    ref.read(persistenceServiceProvider).setHasSeenOnboarding(true);
    // Navigate to the main app flow (AuthGuard)
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGuard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  _OnboardingPage(
                    icon: FontAwesomeIcons.film,
                    title: "Welcome to PlotTwists",
                    description:
                        "Your ultimate companion for tracking and discovering movies and TV shows.",
                  ),
                  _OnboardingPage(
                    icon: FontAwesomeIcons.compass,
                    title: "Discover Hidden Gems",
                    description:
                        "Swipe through personalized recommendations and find your next favorite.",
                  ),
                  _OnboardingPage(
                    icon: FontAwesomeIcons.solidBookmark,
                    title: "Curate Your Universe",
                    description:
                        "Manage your watchlist, history, and create custom lists for any mood or occasion.",
                  ),
                ],
              ),
            ),
            // Bottom Controls (Dots and Buttons)
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skip Button
          TextButton(
            onPressed: () => _onOnboardingComplete(context as WidgetRef),
            child: const Text(
              "Skip",
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
          ),
          // Dot Indicators
          Row(
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: 300.ms,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.auroraPink
                      : AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
          ),
          // Next / Get Started Button
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () {
                  if (_currentPage == 2) {
                    _onOnboardingComplete(ref);
                  } else {
                    _pageController.nextPage(
                      duration: 300.ms,
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.auroraPink,
                  foregroundColor: Colors.white,
                ),
                child: Text(_currentPage == 2 ? "Get Started" : "Next"),
              );
            },
          ),
        ],
      ),
    );
  }
}

// A reusable widget for each page of the onboarding flow
class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            icon,
            size: 100,
            color: AppColors.auroraPink,
          ).animate().scale(duration: 500.ms, curve: Curves.bounceOut),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.darkTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
    );
  }
}
