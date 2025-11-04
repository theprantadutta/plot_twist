import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/appearance_provider.dart';
import '../../core/app_colors.dart';
import 'widgets/settings_section.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appearanceProvider);
    final notifier = ref.read(appearanceProvider.notifier);

    // Our curated list of accent colors
    final List<Color> accentColors = [
      AppColors.auroraPink,
      Colors.green.shade400,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.purple.shade300,
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text("Appearance"),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- THEME SECTION ---
            SettingsSection(
              title: "Theme",
              children: [
                _ThemeOption(
                  title: "Light",
                  icon: Icons.wb_sunny_rounded,
                  isSelected: appearance.themeMode == ThemeMode.light,
                  onTap: () => notifier.setThemeMode(ThemeMode.light),
                ),
                _ThemeOption(
                  title: "Dark",
                  icon: Icons.nightlight_round,
                  isSelected: appearance.themeMode == ThemeMode.dark,
                  onTap: () => notifier.setThemeMode(ThemeMode.dark),
                ),
                _ThemeOption(
                  title: "System",
                  icon: Icons.settings_brightness_rounded,
                  isSelected: appearance.themeMode == ThemeMode.system,
                  onTap: () => notifier.setThemeMode(ThemeMode.system),
                ),
              ],
            ),

            // --- ACCENT COLOR SECTION ---
            SettingsSection(
              title: "Accent Color",
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: accentColors.map((color) {
                      return GestureDetector(
                        onTap: () => notifier.setAccentColor(color),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: color,
                          // Show a checkmark if this is the selected color
                          child: appearance.accentColor.value == color.value
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // --- MORE OPTIONS SECTION ---
            SettingsSection(
              title: "More Options",
              children: [
                SwitchListTile(
                  title: const Text("OLED / True Black Mode"),
                  subtitle: const Text(
                    "Uses a pure black background to save battery on OLED screens.",
                  ),
                  value: appearance.useTrueBlack,
                  onChanged: notifier.setTrueBlack,
                  activeThumbColor:
                      appearance.accentColor, // Use the selected accent color
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// A private helper widget for the theme options
class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: isSelected ? accentColor : AppColors.darkTextSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? accentColor : Colors.white,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.auroraPink)
          : null,
    );
  }
}
