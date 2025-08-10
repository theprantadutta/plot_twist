import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';
import '../create_custom_list_screen.dart';

/// Widget for selecting custom list themes with visual previews
class ThemeSelectionWidget extends StatefulWidget {
  final List<CustomListTheme> themes;
  final String selectedTheme;
  final ValueChanged<String> onThemeSelected;

  const ThemeSelectionWidget({
    super.key,
    required this.themes,
    required this.selectedTheme,
    required this.onThemeSelected,
  });

  @override
  State<ThemeSelectionWidget> createState() => _ThemeSelectionWidgetState();
}

class _ThemeSelectionWidgetState extends State<ThemeSelectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _themeAnimationControllers;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _themeAnimationControllers = List.generate(
      widget.themes.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _themeAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animationController,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: widget.themes.length,
            itemBuilder: (context, index) {
              final theme = widget.themes[index];
              final isSelected = theme.id == widget.selectedTheme;

              return TweenAnimationBuilder<double>(
                duration:
                    MotionPresets.slideUp.duration +
                    Duration(milliseconds: index * 100),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: MotionPresets.slideUp.curve,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _buildThemeCard(theme, isSelected, index),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(CustomListTheme theme, bool isSelected, int index) {
    return AnimatedBuilder(
      animation: _themeAnimationControllers[index],
      builder: (context, child) {
        final scaleValue =
            1.0 + (_themeAnimationControllers[index].value * 0.05);

        return Transform.scale(
          scale: scaleValue,
          child: GestureDetector(
            onTap: () => _selectTheme(theme.id, index),
            onTapDown: (_) => _themeAnimationControllers[index].forward(),
            onTapUp: (_) => _themeAnimationControllers[index].reverse(),
            onTapCancel: () => _themeAnimationControllers[index].reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColor
                      : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Gradient Background
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(gradient: theme.gradient),
                      ),
                    ),

                    // Dark Overlay for Text Readability
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                            stops: const [0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Selection Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: theme.primaryColor,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              ],
                            ),

                            const Spacer(),

                            // Theme Info
                            Text(
                              theme.name,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              theme.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Shimmer Effect for Selected Theme
                    if (isSelected)
                      Positioned.fill(child: _buildShimmerEffect()),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: -1.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.1),
                Colors.transparent,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectTheme(String themeId, int index) {
    if (themeId != widget.selectedTheme) {
      widget.onThemeSelected(themeId);
    }
  }
}
