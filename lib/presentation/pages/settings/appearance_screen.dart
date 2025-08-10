import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/appearance_provider.dart';
import '../../core/app_colors.dart';
import '../../core/widgets/theme_aware_widget.dart';
import '../../core/widgets/theme_toggle_button.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceNotifierProvider);
    final notifier = ref.read(appearanceNotifierProvider.notifier);

    // Enhanced curated list of cinematic accent colors
    final List<Color> accentColors = [
      AppColors.cinematicGold,
      AppColors.cinematicRed,
      AppColors.cinematicBlue,
      AppColors.cinematicPurple,
      AppColors.auroraPink,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
    ];

    return ThemeAwareWidget(
      builder: (context, isDarkMode, appearanceState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Appearance"),
            actions: [
              // Quick theme toggle button in app bar
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ThemeToggleButton(size: 40),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // --- THEME MODE SELECTOR ---
                ThemeAwareCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Theme Mode",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      const ThemeModeSelector(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                // --- QUICK THEME TOGGLE ---
                ThemeAwareCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quick Toggle",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const ThemeToggleButton(size: 56),
                          const SizedBox(width: 16),
                          const ThemeToggleSwitch(),
                          const Spacer(),
                          Text(
                            isDarkMode ? "Dark Mode" : "Light Mode",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // --- ACCENT COLOR SECTION ---
                ThemeAwareCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Accent Color",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: accentColors.map((color) {
                          final isSelected =
                              appearance.accentColor.toARGB32() ==
                              color.toARGB32();
                          return GestureDetector(
                            onTap: () => notifier.setAccentColorWithTransition(
                              context,
                              color,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOutCubic,
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: isSelected ? 8 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // --- ADVANCED OPTIONS SECTION ---
                ThemeAwareCard(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Advanced Options",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("OLED / True Black Mode"),
                        subtitle: const Text(
                          "Uses pure black background to save battery on OLED screens",
                        ),
                        value: appearance.useTrueBlack,
                        onChanged: notifier.setTrueBlack,
                        activeColor: appearance.accentColor,
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Follow System Theme"),
                        subtitle: const Text(
                          "Automatically switch theme based on system settings",
                        ),
                        value: appearance.followSystemTheme,
                        onChanged: (value) {
                          if (value) {
                            notifier.setThemeModeWithTransition(
                              context,
                              ThemeMode.system,
                            );
                          } else {
                            final currentBrightness = appearance
                                .getEffectiveBrightness(context);
                            final newMode = currentBrightness == Brightness.dark
                                ? ThemeMode.dark
                                : ThemeMode.light;
                            notifier.setThemeModeWithTransition(
                              context,
                              newMode,
                            );
                          }
                        },
                        activeColor: appearance.accentColor,
                      ),
                    ],
                  ),
                ),

                // --- THEME PREVIEW SECTION ---
                if (appearance.isTransitioning)
                  ThemeAwareCard(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          "Applying theme changes...",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
