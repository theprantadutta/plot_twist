// lib/presentation/core/app_entry.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_twist/application/home/home_providers.dart';

import '../onboarding/onboarding_screen.dart';
import 'auth_guard.dart';

class AppEntry extends ConsumerWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the persistence service instance
    final persistenceService = ref.watch(persistenceServiceProvider);

    // Check the flag
    final hasSeenOnboarding = persistenceService.hasSeenOnboarding();

    if (hasSeenOnboarding) {
      // If they've seen it, go to the AuthGuard
      return const AuthGuard();
    } else {
      // If it's their first time, show the OnboardingScreen
      return const OnboardingScreen();
    }
  }
}
