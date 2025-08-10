// lib/presentation/core/app_entry.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot_twist/application/home/home_providers.dart';

import '../../application/settings/system_theme_listener.dart';
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

    // Wrap the entire app with system theme listener
    return SystemThemeListenerWidget(
      child: hasSeenOnboarding ? const AuthGuard() : const OnboardingScreen(),
    );
  }
}
