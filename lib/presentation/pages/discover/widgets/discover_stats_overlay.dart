import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';

/// Stats overlay showing swipe statistics during discovery session
class DiscoverStatsOverlay extends StatefulWidget {
  final int totalSwipes;
  final int likes;
  final int dislikes;
  final int superLikes;

  const DiscoverStatsOverlay({
    super.key,
    required this.totalSwipes,
    required this.likes,
    required this.dislikes,
    required this.superLikes,
  });

  @override
  State<DiscoverStatsOverlay> createState() => _DiscoverStatsOverlayState();
}

class _DiscoverStatsOverlayState extends State<DiscoverStatsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  int _previousTotal = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(DiscoverStatsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when stats change
    if (widget.totalSwipes > _previousTotal) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
      _previousTotal = widget.totalSwipes;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalSwipes == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.cinematicGold.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Total Swipes
                  _buildStatItem(
                    icon: Icons.swipe_rounded,
                    value: widget.totalSwipes,
                    color: AppColors.cinematicGold,
                  ),

                  if (widget.superLikes > 0) ...[
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.star_rounded,
                      value: widget.superLikes,
                      color: AppColors.cinematicGold,
                    ),
                  ],

                  if (widget.likes > 0) ...[
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.favorite_rounded,
                      value: widget.likes,
                      color: Colors.green,
                    ),
                  ],

                  if (widget.dislikes > 0) ...[
                    const SizedBox(width: 16),
                    _buildStatItem(
                      icon: Icons.close_rounded,
                      value: widget.dislikes,
                      color: Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: AppTypography.labelMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
