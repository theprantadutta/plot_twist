import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import '../app_typography.dart';
import '../app_animations.dart';

/// Enhanced cinematic app bar with multiple style variations
/// Supports transparent overlay, glassmorphism, and solid styles
class CinematicAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final CinematicAppBarStyle style;
  final double elevation;
  final Color? backgroundColor;
  final bool centerTitle;
  final double? titleSpacing;
  final double toolbarHeight;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final VoidCallback? onBackPressed;

  const CinematicAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.style = CinematicAppBarStyle.solid,
    this.elevation = 0,
    this.backgroundColor,
    this.centerTitle = true,
    this.titleSpacing,
    this.toolbarHeight = kToolbarHeight,
    this.systemOverlayStyle,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  State<CinematicAppBar> createState() => _CinematicAppBarState();
}

class _CinematicAppBarState extends State<CinematicAppBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _slideController.forward();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: MotionPresets.slideDown.duration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: MotionPresets.slideDown.curve,
          ),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: _buildAppBarContent(),
    );
  }

  Widget _buildAppBarContent() {
    switch (widget.style) {
      case CinematicAppBarStyle.transparent:
        return _buildTransparentAppBar();
      case CinematicAppBarStyle.glassmorphism:
        return _buildGlassmorphismAppBar();
      case CinematicAppBarStyle.solid:
        return _buildSolidAppBar();
    }
  }

  Widget _buildTransparentAppBar() {
    return AppBar(
      title: _buildTitle(),
      actions: widget.actions,
      leading: _buildLeading(),
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: widget.centerTitle,
      titleSpacing: widget.titleSpacing,
      toolbarHeight: widget.toolbarHeight,
      systemOverlayStyle:
          widget.systemOverlayStyle ??
          SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.3),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphismAppBar() {
    return SizedBox(
      height: widget.toolbarHeight + MediaQuery.of(context).padding.top,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.navigationGlass,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.glassmorphismBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: AppBar(
              title: _buildTitle(),
              actions: widget.actions,
              leading: _buildLeading(),
              automaticallyImplyLeading: widget.automaticallyImplyLeading,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: widget.centerTitle,
              titleSpacing: widget.titleSpacing,
              toolbarHeight: widget.toolbarHeight,
              systemOverlayStyle:
                  widget.systemOverlayStyle ??
                  SystemUiOverlayStyle.light.copyWith(
                    statusBarColor: Colors.transparent,
                    statusBarBrightness: Brightness.dark,
                    statusBarIconBrightness: Brightness.light,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolidAppBar() {
    return AppBar(
      title: _buildTitle(),
      actions: widget.actions,
      leading: _buildLeading(),
      automaticallyImplyLeading: widget.automaticallyImplyLeading,
      backgroundColor: widget.backgroundColor ?? AppColors.darkSurface,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      titleSpacing: widget.titleSpacing,
      toolbarHeight: widget.toolbarHeight,
      systemOverlayStyle:
          widget.systemOverlayStyle ??
          SystemUiOverlayStyle.light.copyWith(
            statusBarColor: widget.backgroundColor ?? AppColors.darkSurface,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
      shadowColor: AppColors.cinematicGold.withValues(alpha: 0.1),
    );
  }

  Widget? _buildTitle() {
    if (widget.titleWidget != null) {
      return widget.titleWidget;
    }

    if (widget.title != null) {
      return AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 300),
        style: AppTypography.headlineSmall.copyWith(
          color: _getTitleColor(),
          fontWeight: FontWeight.w600,
        ),
        child: Text(widget.title!),
      );
    }

    return null;
  }

  Widget? _buildLeading() {
    if (widget.leading != null) {
      return widget.leading;
    }

    if (widget.automaticallyImplyLeading && Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: _getIconColor(),
          size: 22,
        ),
        onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }

    return null;
  }

  Color _getTitleColor() {
    switch (widget.style) {
      case CinematicAppBarStyle.transparent:
      case CinematicAppBarStyle.glassmorphism:
        return Colors.white;
      case CinematicAppBarStyle.solid:
        return AppColors.darkTextPrimary;
    }
  }

  Color _getIconColor() {
    switch (widget.style) {
      case CinematicAppBarStyle.transparent:
      case CinematicAppBarStyle.glassmorphism:
        return Colors.white;
      case CinematicAppBarStyle.solid:
        return AppColors.darkTextPrimary;
    }
  }
}

/// App bar style variations
enum CinematicAppBarStyle {
  /// Transparent overlay for hero sections
  transparent,

  /// Glassmorphism with blur effect
  glassmorphism,

  /// Solid background for content pages
  solid,
}

/// Specialized app bar variants for different contexts
class TransparentOverlayAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const TransparentOverlayAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CinematicAppBar(
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      style: CinematicAppBarStyle.transparent,
      onBackPressed: onBackPressed,
    );
  }
}

class GlassmorphismAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBackPressed;

  const GlassmorphismAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CinematicAppBar(
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      style: CinematicAppBarStyle.glassmorphism,
      onBackPressed: onBackPressed,
    );
  }
}

class SolidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;
  final VoidCallback? onBackPressed;

  const SolidAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 2,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CinematicAppBar(
      title: title,
      titleWidget: titleWidget,
      actions: actions,
      leading: leading,
      style: CinematicAppBarStyle.solid,
      backgroundColor: backgroundColor,
      elevation: elevation,
      onBackPressed: onBackPressed,
    );
  }
}

/// App bar transition controller for smooth style changes
class AppBarTransitionController extends StatefulWidget {
  final Widget child;
  final CinematicAppBarStyle initialStyle;
  final Duration transitionDuration;

  const AppBarTransitionController({
    super.key,
    required this.child,
    this.initialStyle = CinematicAppBarStyle.solid,
    this.transitionDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AppBarTransitionController> createState() =>
      AppBarTransitionControllerState();

  static AppBarTransitionControllerState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppBarTransitionControllerState>();
  }
}

class AppBarTransitionControllerState extends State<AppBarTransitionController>
    with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late CinematicAppBarStyle _currentStyle;

  @override
  void initState() {
    super.initState();
    _currentStyle = widget.initialStyle;
    _transitionController = AnimationController(
      duration: widget.transitionDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void transitionTo(CinematicAppBarStyle newStyle) {
    if (_currentStyle != newStyle) {
      setState(() {
        _currentStyle = newStyle;
      });
      _transitionController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Common app bar actions for cinematic interface
class CinematicAppBarActions {
  static Widget searchAction({
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return IconButton(
      icon: Icon(
        Icons.search_rounded,
        color: iconColor ?? Colors.white,
        size: 24,
      ),
      onPressed: onPressed,
      tooltip: 'Search',
    );
  }

  static Widget moreAction({
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return IconButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: iconColor ?? Colors.white,
        size: 24,
      ),
      onPressed: onPressed,
      tooltip: 'More options',
    );
  }

  static Widget favoriteAction({
    required bool isFavorite,
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          key: ValueKey(isFavorite),
          color: isFavorite
              ? AppColors.cinematicGold
              : (iconColor ?? Colors.white),
          size: 24,
        ),
      ),
      onPressed: onPressed,
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }

  static Widget shareAction({
    required VoidCallback onPressed,
    Color? iconColor,
  }) {
    return IconButton(
      icon: Icon(
        Icons.share_rounded,
        color: iconColor ?? Colors.white,
        size: 24,
      ),
      onPressed: onPressed,
      tooltip: 'Share',
    );
  }
}
