import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/settings/appearance_provider.dart';
import '../app_colors.dart';

/// A beautiful animated theme toggle button
class ThemeToggleButton extends ConsumerStatefulWidget {
  final double size;
  final Color? lightModeColor;
  final Color? darkModeColor;
  final Color? backgroundColor;
  final bool showLabel;
  final String? lightModeLabel;
  final String? darkModeLabel;

  const ThemeToggleButton({
    super.key,
    this.size = 48.0,
    this.lightModeColor,
    this.darkModeColor,
    this.backgroundColor,
    this.showLabel = false,
    this.lightModeLabel = 'Light Mode',
    this.darkModeLabel = 'Dark Mode',
  });

  @override
  ConsumerState<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends ConsumerState<ThemeToggleButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPressed() async {
    // Scale animation for press feedback
    await _scaleController.forward();
    _scaleController.reverse();

    // Rotation animation
    _rotationController.forward().then((_) {
      _rotationController.reset();
    });

    // Toggle theme with transition
    if (mounted) {
      await ref
          .read(appearanceNotifierProvider.notifier)
          .toggleThemeWithTransition(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    final effectiveLightColor =
        widget.lightModeColor ?? AppColors.cinematicGold;
    final effectiveDarkColor = widget.darkModeColor ?? AppColors.cinematicGold;
    final effectiveBackgroundColor =
        widget.backgroundColor ??
        (isDarkMode ? AppColors.darkSurface : AppColors.lightSurface);

    // Generate semantic label
    final semanticLabel =
        'Toggle theme, currently ${isDarkMode ? 'dark' : 'light'} mode';
    final tooltip = 'Switch to ${isDarkMode ? 'light' : 'dark'} mode';

    return Semantics(
      label: semanticLabel,
      button: true,
      hint: 'Double tap to toggle between light and dark themes',
      child: Tooltip(
        message: tooltip,
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: effectiveBackgroundColor,
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDarkMode ? 0.3 : 0.1,
                      ),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    onTap: _onPressed,
                    child: Center(
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: TweenAnimationBuilder<Color?>(
                          duration: const Duration(milliseconds: 300),
                          tween: ColorTween(
                            end: isDarkMode
                                ? effectiveDarkColor
                                : effectiveLightColor,
                          ),
                          builder: (context, color, child) {
                            return Icon(
                              isDarkMode
                                  ? Icons.light_mode_rounded
                                  : Icons.dark_mode_rounded,
                              color: color,
                              size: widget.size * 0.5,
                              semanticLabel: isDarkMode
                                  ? 'Light mode icon'
                                  : 'Dark mode icon',
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A theme toggle switch with smooth animations
class ThemeToggleSwitch extends ConsumerWidget {
  final double width;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const ThemeToggleSwitch({
    super.key,
    this.width = 60.0,
    this.height = 32.0,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final isDarkMode = appearanceState.isDarkMode(context);

    return GestureDetector(
      onTap: () async {
        await ref
            .read(appearanceNotifierProvider.notifier)
            .toggleThemeWithTransition(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          color: isDarkMode
              ? (activeColor ?? AppColors.cinematicGold.withValues(alpha: 0.3))
              : (inactiveColor ??
                    AppColors.lightTextTertiary.withValues(alpha: 0.3)),
          border: Border.all(
            color: isDarkMode
                ? (activeColor ?? AppColors.cinematicGold)
                : (inactiveColor ?? AppColors.lightTextTertiary),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isDarkMode ? width - height + 2 : 2,
              top: 2,
              child: Container(
                width: height - 4,
                height: height - 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular((height - 4) / 2),
                  color: thumbColor ?? Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: (height - 4) * 0.6,
                    color: isDarkMode
                        ? AppColors.darkBackground
                        : AppColors.cinematicGold,
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

/// A theme mode selector with three options: Light, Dark, System
class ThemeModeSelector extends ConsumerWidget {
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const ThemeModeSelector({super.key, this.padding, this.borderRadius = 12.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);
    final currentMode = appearanceState.themeMode;

    return Container(
      padding: padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeButton(
            context: context,
            ref: ref,
            mode: ThemeMode.light,
            icon: Icons.light_mode_rounded,
            label: 'Light',
            isSelected: currentMode == ThemeMode.light,
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            context: context,
            ref: ref,
            mode: ThemeMode.dark,
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            isSelected: currentMode == ThemeMode.dark,
          ),
          const SizedBox(width: 4),
          _buildModeButton(
            context: context,
            ref: ref,
            mode: ThemeMode.system,
            icon: Icons.settings_rounded,
            label: 'System',
            isSelected: currentMode == ThemeMode.system,
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius - 4),
          border: isSelected
              ? Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius - 4),
            onTap: () async {
              await ref
                  .read(appearanceNotifierProvider.notifier)
                  .setThemeModeWithTransition(context, mode);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
