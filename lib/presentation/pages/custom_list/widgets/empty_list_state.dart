import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';
import '../create_custom_list_screen.dart';

/// Empty state widget for custom lists with inspiring content suggestions
class EmptyListState extends StatefulWidget {
  final CustomListTheme theme;
  final VoidCallback onAddContent;

  const EmptyListState({
    super.key,
    required this.theme,
    required this.onAddContent,
  });

  @override
  State<EmptyListState> createState() => _EmptyListStateState();
}

class _EmptyListStateState extends State<EmptyListState>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: MotionPresets.slideUp.curve,
          ),
        );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Animated Icon
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: widget.theme.gradient,
                            boxShadow: [
                              BoxShadow(
                                color: widget.theme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.movie_creation_outlined,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    'Your List Awaits',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Start building your curated collection of movies and TV shows. Every great list begins with a single addition.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.darkTextSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Add Content Button
                  ElevatedButton.icon(
                    onPressed: widget.onAddContent,
                    icon: Icon(Icons.add_rounded),
                    label: Text(
                      'Add Your First Item',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.primaryColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: widget.theme.primaryColor.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Suggestions
                  _buildSuggestions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      {
        'icon': Icons.trending_up_rounded,
        'title': 'Trending Now',
        'description': 'Add popular movies and shows',
      },
      {
        'icon': Icons.star_rounded,
        'title': 'Top Rated',
        'description': 'Include critically acclaimed content',
      },
      {
        'icon': Icons.favorite_rounded,
        'title': 'Personal Favorites',
        'description': 'Add your all-time favorites',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get Started With',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        for (final entry in suggestions.asMap().entries) ...[
          Builder(
            builder: (context) {
              final index = entry.key;
              final suggestion = entry.value;

              return TweenAnimationBuilder<double>(
                duration:
                    MotionPresets.slideUp.duration +
                    Duration(milliseconds: index * 200),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: MotionPresets.slideUp.curve,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.theme.primaryColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.theme.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          suggestion['icon'] as IconData,
                          color: widget.theme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion['title'] as String,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              suggestion['description'] as String,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.darkTextTertiary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
