import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';

/// Enhanced progress indicators for library items with visual cues
class WatchProgressIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Duration? totalDuration;
  final Duration? watchedDuration;
  final bool showTime;
  final Color? progressColor;
  final double size;
  final VoidCallback? onTap;

  const WatchProgressIndicator({
    super.key,
    required this.progress,
    this.totalDuration,
    this.watchedDuration,
    this.showTime = true,
    this.progressColor,
    this.size = 48,
    this.onTap,
  });

  @override
  State<WatchProgressIndicator> createState() => _WatchProgressIndicatorState();
}

class _WatchProgressIndicatorState extends State<WatchProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(WatchProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation =
          Tween<double>(
            begin: oldWidget.progress,
            end: widget.progress,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutCubic,
            ),
          );
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = widget.progressColor ?? AppColors.cinematicGold;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: AnimatedContainer(
          duration: MotionPresets.hover.duration,
          transform: Matrix4.identity()..scale(_isHovered ? 1.1 : 1.0),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(
                color: progressColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                if (_isHovered)
                  BoxShadow(
                    color: progressColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Circle
                CircularProgressIndicator(
                  value: 1.0,
                  backgroundColor: AppColors.darkTextTertiary.withValues(
                    alpha: 0.2,
                  ),
                  color: Colors.transparent,
                  strokeWidth: 3,
                ),

                // Progress Circle
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.transparent,
                      color: progressColor,
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),

                // Center Content
                Center(
                  child: widget.showTime && widget.watchedDuration != null
                      ? _buildTimeDisplay()
                      : _buildPercentageDisplay(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageDisplay() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final percentage = (_progressAnimation.value * 100).round();
        return Text(
          '$percentage%',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        );
      },
    );
  }

  Widget _buildTimeDisplay() {
    final watched = widget.watchedDuration!;
    final hours = watched.inHours;
    final minutes = watched.inMinutes % 60;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          hours > 0 ? '${hours}h' : '${minutes}m',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 9,
          ),
        ),
        if (hours > 0 && minutes > 0)
          Text(
            '${minutes}m',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.darkTextSecondary,
              fontSize: 7,
            ),
          ),
      ],
    );
  }
}

/// Priority indicator for watchlist items
class PriorityIndicator extends StatelessWidget {
  final WatchPriority priority;
  final bool showLabel;
  final double size;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.showLabel = false,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: showLabel ? 8 : 4, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priority.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, color: priority.color, size: size * 0.7),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              priority.label,
              style: AppTypography.labelSmall.copyWith(
                color: priority.color,
                fontWeight: FontWeight.w600,
                fontSize: size * 0.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Completion status overlay for watched items
class CompletionStatusOverlay extends StatefulWidget {
  final CompletionStatus status;
  final double? rating;
  final DateTime? watchedDate;
  final bool showDetails;
  final VoidCallback? onTap;

  const CompletionStatusOverlay({
    super.key,
    required this.status,
    this.rating,
    this.watchedDate,
    this.showDetails = false,
    this.onTap,
  });

  @override
  State<CompletionStatusOverlay> createState() =>
      _CompletionStatusOverlayState();
}

class _CompletionStatusOverlayState extends State<CompletionStatusOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.status.color.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.status.color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.status.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.status.icon,
                        color: widget.status.color,
                        size: 18,
                      ),
                    ),

                    if (widget.showDetails) ...[
                      const SizedBox(height: 8),

                      // Status Label
                      Text(
                        widget.status.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: widget.status.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Rating (if available)
                      if (widget.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.cinematicGold,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.rating!.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Watch Date (if available)
                      if (widget.watchedDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(widget.watchedDate!),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.darkTextSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Quick action button with micro-interactions
class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool isActive;
  final double size;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isActive = false,
    this.size = 40,
  });

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.isActive
                      ? widget.color
                      : widget.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    if (_isPressed)
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isActive ? Colors.white : widget.color,
                  size: widget.size * 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Rating overlay with visual feedback
class RatingOverlay extends StatefulWidget {
  final double rating;
  final int voteCount;
  final bool showVoteCount;
  final double size;
  final VoidCallback? onTap;

  const RatingOverlay({
    super.key,
    required this.rating,
    this.voteCount = 0,
    this.showVoteCount = false,
    this.size = 48,
    this.onTap,
  });

  @override
  State<RatingOverlay> createState() => _RatingOverlayState();
}

class _RatingOverlayState extends State<RatingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.rating / 10.0)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratingColor = AppColors.getRatingColor(widget.rating);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: AppColors.darkBackground.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ratingColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ratingColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Progress Ring
                  CircularProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: AppColors.darkTextTertiary.withValues(
                      alpha: 0.3,
                    ),
                    color: ratingColor,
                    strokeWidth: 3,
                    strokeCap: StrokeCap.round,
                  ),

                  // Rating Content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.rating.toStringAsFixed(1),
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: widget.size * 0.25,
                          ),
                        ),
                        if (widget.showVoteCount && widget.voteCount > 0)
                          Text(
                            '${widget.voteCount}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.darkTextSecondary,
                              fontSize: widget.size * 0.15,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Enums for different states and priorities
enum WatchPriority {
  high('High', Icons.priority_high_rounded, AppColors.cinematicRed),
  medium('Medium', Icons.remove_rounded, AppColors.cinematicGold),
  low('Low', Icons.keyboard_arrow_down_rounded, AppColors.cinematicBlue);

  const WatchPriority(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

enum CompletionStatus {
  completed(
    'Completed',
    Icons.check_circle_rounded,
    AppColors.darkSuccessGreen,
  ),
  inProgress('In Progress', Icons.play_circle_rounded, AppColors.cinematicBlue),
  paused('Paused', Icons.pause_circle_rounded, AppColors.cinematicGold),
  dropped('Dropped', Icons.cancel_rounded, AppColors.cinematicRed);

  const CompletionStatus(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}
