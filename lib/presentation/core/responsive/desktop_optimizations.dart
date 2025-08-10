import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
import 'responsive_layout.dart';

/// Desktop and web optimizations for enhanced user experience
class DesktopOptimizations {
  /// Check if current platform supports desktop features
  static bool get isDesktopPlatform {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Check if current platform is web
  static bool get isWebPlatform => kIsWeb;

  /// Get appropriate cursor for interactive elements
  static SystemMouseCursor getCursor(InteractionType type) {
    if (!isDesktopPlatform) return SystemMouseCursors.basic;

    switch (type) {
      case InteractionType.click:
        return SystemMouseCursors.click;
      case InteractionType.grab:
        return SystemMouseCursors.grab;
      case InteractionType.grabbing:
        return SystemMouseCursors.grabbing;
      case InteractionType.resize:
        return SystemMouseCursors.resizeColumn;
      case InteractionType.text:
        return SystemMouseCursors.text;
      case InteractionType.forbidden:
        return SystemMouseCursors.forbidden;
      case InteractionType.help:
        return SystemMouseCursors.help;
      case InteractionType.wait:
        return SystemMouseCursors.wait;
    }
  }

  /// Get desktop-specific layout constraints
  static BoxConstraints getDesktopConstraints(BuildContext context) {
    if (!ResponsiveBreakpoints.isDesktop(context)) {
      return const BoxConstraints();
    }

    return BoxConstraints(
      maxWidth: ResponsiveBreakpoints.getResponsiveValue(
        context,
        mobile: double.infinity,
        tablet: 768.0,
        desktop: 1200.0,
        largeDesktop: 1400.0,
      ),
    );
  }

  /// Get desktop-specific spacing
  static double getDesktopSpacing(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
      largeDesktop: 48.0,
    );
  }
}

/// Interaction type enumeration for cursor management
enum InteractionType {
  click,
  grab,
  grabbing,
  resize,
  text,
  forbidden,
  help,
  wait,
}

/// Keyboard navigation mixin for widgets
mixin KeyboardNavigationMixin<T extends StatefulWidget> on State<T> {
  FocusNode? _focusNode;
  bool _isHovered = false;
  bool _isFocused = false;

  FocusNode get focusNode => _focusNode ??= FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChanged);
    _focusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = focusNode.hasFocus;
    });
  }

  void _onHoverChanged(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  /// Handle keyboard events
  bool handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          onActivate();
          return true;
        case LogicalKeyboardKey.escape:
          onEscape();
          return true;
        case LogicalKeyboardKey.arrowUp:
          onArrowUp();
          return true;
        case LogicalKeyboardKey.arrowDown:
          onArrowDown();
          return true;
        case LogicalKeyboardKey.arrowLeft:
          onArrowLeft();
          return true;
        case LogicalKeyboardKey.arrowRight:
          onArrowRight();
          return true;
        case LogicalKeyboardKey.tab:
          onTab(HardwareKeyboard.instance.isShiftPressed);
          return true;
      }
    }
    return false;
  }

  /// Build keyboard navigable widget
  Widget buildKeyboardNavigable({
    required Widget child,
    VoidCallback? onTap,
    String? semanticLabel,
    bool autofocus = false,
  }) {
    if (!DesktopOptimizations.isDesktopPlatform) {
      return child;
    }

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      cursor: DesktopOptimizations.getCursor(InteractionType.click),
      child: Focus(
        focusNode: focusNode,
        autofocus: autofocus,
        onKeyEvent: (node, event) {
          return handleKeyEvent(event)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: onTap,
          child: Semantics(
            label: semanticLabel,
            button: onTap != null,
            focusable: true,
            focused: _isFocused,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: _isFocused
                    ? Border.all(color: AppColors.cinematicPurple, width: 2)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  /// Override these methods in implementing widgets
  void onActivate() {}
  void onEscape() {}
  void onArrowUp() {}
  void onArrowDown() {}
  void onArrowLeft() {}
  void onArrowRight() {}
  void onTab(bool isShiftPressed) {}

  /// Getters for state
  bool get isHovered => _isHovered;
  bool get isFocused => _isFocused;
}

/// Desktop-optimized button with keyboard navigation
class DesktopButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final String? semanticLabel;
  final bool autofocus;

  const DesktopButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.semanticLabel,
    this.autofocus = false,
  });

  @override
  State<DesktopButton> createState() => _DesktopButtonState();
}

class _DesktopButtonState extends State<DesktopButton>
    with KeyboardNavigationMixin {
  @override
  void onActivate() {
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return buildKeyboardNavigable(
      onTap: widget.onPressed,
      semanticLabel: widget.semanticLabel,
      autofocus: widget.autofocus,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: widget.style?.copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppColors.cinematicPurple.withValues(alpha: 0.1);
            }
            return null;
          }),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Desktop-optimized icon button
class DesktopIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;
  final String? tooltip;
  final String? semanticLabel;
  final bool autofocus;

  const DesktopIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size,
    this.tooltip,
    this.semanticLabel,
    this.autofocus = false,
  });

  @override
  State<DesktopIconButton> createState() => _DesktopIconButtonState();
}

class _DesktopIconButtonState extends State<DesktopIconButton>
    with KeyboardNavigationMixin {
  @override
  void onActivate() {
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget button = buildKeyboardNavigable(
      onTap: widget.onPressed,
      semanticLabel: widget.semanticLabel ?? widget.tooltip,
      autofocus: widget.autofocus,
      child: IconButton(
        onPressed: widget.onPressed,
        icon: Icon(widget.icon),
        color: widget.color,
        iconSize: widget.size,
        tooltip: widget.tooltip,
        hoverColor: AppColors.cinematicPurple.withValues(alpha: 0.1),
        focusColor: AppColors.cinematicPurple.withValues(alpha: 0.2),
      ),
    );

    return button;
  }
}

/// Desktop-optimized list tile
class DesktopListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool autofocus;

  const DesktopListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.autofocus = false,
  });

  @override
  State<DesktopListTile> createState() => _DesktopListTileState();
}

class _DesktopListTileState extends State<DesktopListTile>
    with KeyboardNavigationMixin {
  @override
  void onActivate() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return buildKeyboardNavigable(
      onTap: widget.onTap,
      semanticLabel: widget.semanticLabel,
      autofocus: widget.autofocus,
      child: ListTile(
        leading: widget.leading,
        title: widget.title,
        subtitle: widget.subtitle,
        trailing: widget.trailing,
        onTap: widget.onTap,
        hoverColor: AppColors.cinematicPurple.withValues(alpha: 0.05),
        focusColor: AppColors.cinematicPurple.withValues(alpha: 0.1),
      ),
    );
  }
}

/// Desktop-optimized card with hover effects
class DesktopCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final String? semanticLabel;
  final bool autofocus;

  const DesktopCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.semanticLabel,
    this.autofocus = false,
  });

  @override
  State<DesktopCard> createState() => _DesktopCardState();
}

class _DesktopCardState extends State<DesktopCard>
    with KeyboardNavigationMixin, TickerProviderStateMixin {
  late AnimationController _elevationController;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation =
        Tween<double>(
          begin: widget.elevation ?? 2.0,
          end: (widget.elevation ?? 2.0) + 4.0,
        ).animate(
          CurvedAnimation(parent: _elevationController, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _elevationController.dispose();
    super.dispose();
  }

  @override
  void onActivate() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _elevationController.forward();
        setState(() {});
      },
      onExit: (_) {
        _elevationController.reverse();
        setState(() {});
      },
      cursor: widget.onTap != null
          ? DesktopOptimizations.getCursor(InteractionType.click)
          : SystemMouseCursors.basic,
      child: buildKeyboardNavigable(
        onTap: widget.onTap,
        semanticLabel: widget.semanticLabel,
        autofocus: widget.autofocus,
        child: AnimatedBuilder(
          animation: _elevationAnimation,
          builder: (context, child) {
            return Card(
              color: widget.color,
              elevation: _elevationAnimation.value,
              margin: widget.margin,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Desktop-optimized text field
class DesktopTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool autofocus;

  const DesktopTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.autofocus = false,
  });

  @override
  State<DesktopTextField> createState() => _DesktopTextFieldState();
}

class _DesktopTextFieldState extends State<DesktopTextField> {
  late FocusNode _focusNode;
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: DesktopOptimizations.getCursor(InteractionType.text),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovered || _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.cinematicPurple.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(widget.suffixIcon),
                    onPressed: widget.onSuffixIconPressed,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.cinematicPurple,
                width: 2,
              ),
            ),
            hoverColor: AppColors.cinematicPurple.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }
}

/// Window resize handler for responsive layouts
class WindowResizeHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onResize;

  const WindowResizeHandler({super.key, required this.child, this.onResize});

  @override
  State<WindowResizeHandler> createState() => _WindowResizeHandlerState();
}

class _WindowResizeHandlerState extends State<WindowResizeHandler>
    with WidgetsBindingObserver {
  Size? _previousSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _previousSize = MediaQuery.of(context).size;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentSize = MediaQuery.of(context).size;
        if (_previousSize != null && _previousSize != currentSize) {
          widget.onResize?.call();
          _previousSize = currentSize;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Desktop-specific layout wrapper
class DesktopLayoutWrapper extends StatelessWidget {
  final Widget child;
  final bool enableKeyboardNavigation;
  final bool enableWindowResize;
  final VoidCallback? onWindowResize;

  const DesktopLayoutWrapper({
    super.key,
    required this.child,
    this.enableKeyboardNavigation = true,
    this.enableWindowResize = true,
    this.onWindowResize,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Add window resize handling
    if (enableWindowResize && DesktopOptimizations.isDesktopPlatform) {
      content = WindowResizeHandler(onResize: onWindowResize, child: content);
    }

    // Add keyboard navigation shortcuts
    if (enableKeyboardNavigation && DesktopOptimizations.isDesktopPlatform) {
      content = Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: Actions(
          actions: {
            DismissIntent: CallbackAction<DismissIntent>(
              onInvoke: (intent) => Navigator.of(context).maybePop(),
            ),
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (intent) => null,
            ),
          },
          child: content,
        ),
      );
    }

    return content;
  }
}
