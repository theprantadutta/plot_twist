import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_typography.dart';

/// Animated notification system with slide-in animations
class NotificationAnimations {
  /// Show a slide-in notification from the top
  static void showTopNotification(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopNotification(
        message: message,
        title: title,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        duration: duration,
        onTap: onTap,
        onDismiss: () {
          onDismiss?.call();
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration + const Duration(milliseconds: 500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Show a slide-in notification from the bottom
  static void showBottomNotification(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    VoidCallback? onDismiss,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _BottomNotification(
        message: message,
        title: title,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        duration: duration,
        onTap: onTap,
        onDismiss: () {
          onDismiss?.call();
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration + const Duration(milliseconds: 500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// Show a floating action notification
  static void showFloatingNotification(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FloatingNotification(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        duration: duration,
        onTap: onTap,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after duration
    Future.delayed(duration + const Duration(milliseconds: 500), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

/// Top slide-in notification widget
class _TopNotification extends StatefulWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _TopNotification({
    required this.message,
    this.title,
    this.icon,
    this.backgroundColor,
    this.textColor,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_TopNotification> createState() => _TopNotificationState();
}

class _TopNotificationState extends State<_TopNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Start dismiss animation before auto-dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.onTap?.call();
                        _controller.reverse().then((_) => widget.onDismiss());
                      },
                      onPanUpdate: (details) {
                        if (details.delta.dy < -5) {
                          _controller.reverse().then((_) => widget.onDismiss());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              widget.backgroundColor ?? AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color:
                                    widget.textColor ??
                                    AppColors.cinematicPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.title != null) ...[
                                    Text(
                                      widget.title!,
                                      style: AppTypography.titleMedium.copyWith(
                                        color:
                                            widget.textColor ??
                                            AppColors.darkTextPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  Text(
                                    widget.message,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color:
                                          widget.textColor ??
                                          AppColors.darkTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _controller.reverse().then(
                                  (_) => widget.onDismiss(),
                                );
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color:
                                    widget.textColor ??
                                    AppColors.darkTextSecondary,
                                size: 20,
                              ),
                            ),
                          ],
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

/// Bottom slide-in notification widget
class _BottomNotification extends StatefulWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _BottomNotification({
    required this.message,
    this.title,
    this.icon,
    this.backgroundColor,
    this.textColor,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_BottomNotification> createState() => _BottomNotificationState();
}

class _BottomNotificationState extends State<_BottomNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Start dismiss animation before auto-dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: () {
                        widget.onTap?.call();
                        _controller.reverse().then((_) => widget.onDismiss());
                      },
                      onPanUpdate: (details) {
                        if (details.delta.dy > 5) {
                          _controller.reverse().then((_) => widget.onDismiss());
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              widget.backgroundColor ?? AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color:
                                    widget.textColor ??
                                    AppColors.cinematicPurple,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.title != null) ...[
                                    Text(
                                      widget.title!,
                                      style: AppTypography.titleMedium.copyWith(
                                        color:
                                            widget.textColor ??
                                            AppColors.darkTextPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                  Text(
                                    widget.message,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color:
                                          widget.textColor ??
                                          AppColors.darkTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _controller.reverse().then(
                                  (_) => widget.onDismiss(),
                                );
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color:
                                    widget.textColor ??
                                    AppColors.darkTextSecondary,
                                size: 20,
                              ),
                            ),
                          ],
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

/// Floating notification widget
class _FloatingNotification extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _FloatingNotification({
    required this.message,
    this.icon,
    this.backgroundColor,
    this.textColor,
    required this.duration,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_FloatingNotification> createState() => _FloatingNotificationState();
}

class _FloatingNotificationState extends State<_FloatingNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Start dismiss animation before auto-dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    widget.onTap?.call();
                    _controller.reverse().then((_) => widget.onDismiss());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor ?? AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color:
                                widget.textColor ?? AppColors.cinematicPurple,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.message,
                            style: AppTypography.bodyMedium.copyWith(
                              color:
                                  widget.textColor ?? AppColors.darkTextPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Alert dialog with smooth animations
class AnimatedAlertDialog extends StatefulWidget {
  final String title;
  final String content;
  final List<Widget>? actions;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? contentColor;

  const AnimatedAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.icon,
    this.backgroundColor,
    this.titleColor,
    this.contentColor,
  });

  @override
  State<AnimatedAlertDialog> createState() => _AnimatedAlertDialogState();
}

class _AnimatedAlertDialogState extends State<AnimatedAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AlertDialog(
              backgroundColor: widget.backgroundColor ?? AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.titleLarge.copyWith(
                        color: widget.titleColor ?? AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                widget.content,
                style: AppTypography.bodyMedium.copyWith(
                  color: widget.contentColor ?? AppColors.darkTextSecondary,
                ),
              ),
              actions: widget.actions,
            ),
          ),
        );
      },
    );
  }
}

/// Bottom sheet with slide-up animation
class AnimatedBottomSheet extends StatefulWidget {
  final Widget child;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? height;

  const AnimatedBottomSheet({
    super.key,
    required this.child,
    this.isScrollControlled = false,
    this.backgroundColor,
    this.height,
  });

  @override
  State<AnimatedBottomSheet> createState() => _AnimatedBottomSheetState();
}

class _AnimatedBottomSheetState extends State<AnimatedBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.darkSurface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
