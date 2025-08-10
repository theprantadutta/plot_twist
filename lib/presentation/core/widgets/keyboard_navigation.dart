import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget that provides keyboard navigation support
class KeyboardNavigationWrapper extends StatefulWidget {
  final Widget child;
  final List<FocusNode>? focusNodes;
  final bool enableArrowKeyNavigation;
  final bool enableTabNavigation;
  final bool enableEnterActivation;
  final VoidCallback? onEscape;

  const KeyboardNavigationWrapper({
    super.key,
    required this.child,
    this.focusNodes,
    this.enableArrowKeyNavigation = true,
    this.enableTabNavigation = true,
    this.enableEnterActivation = true,
    this.onEscape,
  });

  @override
  State<KeyboardNavigationWrapper> createState() =>
      _KeyboardNavigationWrapperState();
}

class _KeyboardNavigationWrapperState extends State<KeyboardNavigationWrapper> {
  late FocusNode _focusNode;
  int _currentFocusIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final focusNodes = widget.focusNodes;
      if (focusNodes == null || focusNodes.isEmpty) return;

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.arrowRight:
          if (widget.enableArrowKeyNavigation) {
            _moveFocus(1, focusNodes);
          }
          break;
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowLeft:
          if (widget.enableArrowKeyNavigation) {
            _moveFocus(-1, focusNodes);
          }
          break;
        case LogicalKeyboardKey.tab:
          if (widget.enableTabNavigation) {
            final direction = HardwareKeyboard.instance.isShiftPressed ? -1 : 1;
            _moveFocus(direction, focusNodes);
          }
          break;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          if (widget.enableEnterActivation) {
            _activateCurrentFocus(focusNodes);
          }
          break;
        case LogicalKeyboardKey.escape:
          if (widget.onEscape != null) {
            widget.onEscape!();
          }
          break;
      }
    }
  }

  void _moveFocus(int direction, List<FocusNode> focusNodes) {
    _currentFocusIndex = (_currentFocusIndex + direction) % focusNodes.length;
    if (_currentFocusIndex < 0) {
      _currentFocusIndex = focusNodes.length - 1;
    }
    focusNodes[_currentFocusIndex].requestFocus();
  }

  void _activateCurrentFocus(List<FocusNode> focusNodes) {
    final currentNode = focusNodes[_currentFocusIndex];
    if (currentNode.context != null) {
      // Try to activate the focused widget
      final widget = currentNode.context!.widget;
      if (widget is StatefulWidget) {
        // Simulate tap for buttons and other interactive widgets
        final renderObject = currentNode.context!.findRenderObject();
        if (renderObject is RenderBox) {
          // Create a synthetic tap event
          // Note: This is a simplified approach. In practice, you might need
          // to handle different widget types differently.
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: widget.child,
    );
  }
}

/// Mixin to add keyboard navigation support to any widget
mixin KeyboardNavigationMixin<T extends StatefulWidget> on State<T> {
  final List<FocusNode> _focusNodes = [];
  int _currentFocusIndex = 0;

  /// Add a focus node to the navigation list
  void addFocusNode(FocusNode node) {
    _focusNodes.add(node);
  }

  /// Remove a focus node from the navigation list
  void removeFocusNode(FocusNode node) {
    _focusNodes.remove(node);
  }

  /// Handle keyboard navigation
  KeyEventResult handleKeyboardNavigation(KeyEvent event) {
    if (event is KeyDownEvent && _focusNodes.isNotEmpty) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.arrowRight:
          _moveToNextFocus();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.arrowLeft:
          _moveToPreviousFocus();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.tab:
          if (HardwareKeyboard.instance.isShiftPressed) {
            _moveToPreviousFocus();
          } else {
            _moveToNextFocus();
          }
          return KeyEventResult.handled;
        case LogicalKeyboardKey.enter:
        case LogicalKeyboardKey.space:
          _activateCurrentFocus();
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _moveToNextFocus() {
    if (_focusNodes.isEmpty) return;
    _currentFocusIndex = (_currentFocusIndex + 1) % _focusNodes.length;
    _focusNodes[_currentFocusIndex].requestFocus();
  }

  void _moveToPreviousFocus() {
    if (_focusNodes.isEmpty) return;
    _currentFocusIndex = (_currentFocusIndex - 1) % _focusNodes.length;
    if (_currentFocusIndex < 0) {
      _currentFocusIndex = _focusNodes.length - 1;
    }
    _focusNodes[_currentFocusIndex].requestFocus();
  }

  void _activateCurrentFocus() {
    if (_focusNodes.isEmpty) return;
    // Override this method in implementing classes to handle activation
    onFocusActivated(_currentFocusIndex);
  }

  /// Override this method to handle focus activation
  void onFocusActivated(int index) {
    // Default implementation - override in subclasses
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}

/// A focus scope that manages keyboard navigation for its children
class AccessibleFocusScope extends StatefulWidget {
  final Widget child;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  const AccessibleFocusScope({
    super.key,
    required this.child,
    this.autofocus = false,
    this.focusNode,
    this.onFocusChange,
  });

  @override
  State<AccessibleFocusScope> createState() => _AccessibleFocusScopeState();
}

class _AccessibleFocusScopeState extends State<AccessibleFocusScope> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.onFocusChange != null) {
      widget.onFocusChange!(_focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      focusNode: _focusNode,
      child: widget.child,
    );
  }
}

/// Keyboard shortcut handler for common actions
class KeyboardShortcutHandler extends StatelessWidget {
  final Widget child;
  final Map<ShortcutActivator, VoidCallback> shortcuts;

  const KeyboardShortcutHandler({
    super.key,
    required this.child,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    final shortcutMap = <ShortcutActivator, Intent>{};
    final actionMap = <Type, Action<Intent>>{};

    for (final entry in shortcuts.entries) {
      final intent = _CallbackIntent(entry.value);
      shortcutMap[entry.key] = intent;
      actionMap[intent.runtimeType] = _CallbackAction();
    }

    return Shortcuts(
      shortcuts: shortcutMap,
      child: Actions(actions: actionMap, child: child),
    );
  }
}

class _CallbackIntent extends Intent {
  final VoidCallback callback;
  const _CallbackIntent(this.callback);
}

class _CallbackAction extends Action<_CallbackIntent> {
  @override
  Object? invoke(_CallbackIntent intent) {
    intent.callback();
    return null;
  }
}

/// Common keyboard shortcuts for accessibility
class AccessibilityShortcuts {
  static const Map<ShortcutActivator, String> commonShortcuts = {
    SingleActivator(LogicalKeyboardKey.escape): 'Close/Cancel',
    SingleActivator(LogicalKeyboardKey.enter): 'Activate/Confirm',
    SingleActivator(LogicalKeyboardKey.space): 'Activate/Select',
    SingleActivator(LogicalKeyboardKey.tab): 'Next element',
    SingleActivator(LogicalKeyboardKey.tab, shift: true): 'Previous element',
    SingleActivator(LogicalKeyboardKey.arrowDown): 'Next item',
    SingleActivator(LogicalKeyboardKey.arrowUp): 'Previous item',
    SingleActivator(LogicalKeyboardKey.arrowLeft): 'Previous/Back',
    SingleActivator(LogicalKeyboardKey.arrowRight): 'Next/Forward',
    SingleActivator(LogicalKeyboardKey.home): 'First item',
    SingleActivator(LogicalKeyboardKey.end): 'Last item',
    SingleActivator(LogicalKeyboardKey.pageUp): 'Page up',
    SingleActivator(LogicalKeyboardKey.pageDown): 'Page down',
  };

  /// Create shortcuts for common navigation actions
  static Map<ShortcutActivator, VoidCallback> createNavigationShortcuts({
    VoidCallback? onEscape,
    VoidCallback? onEnter,
    VoidCallback? onSpace,
    VoidCallback? onArrowUp,
    VoidCallback? onArrowDown,
    VoidCallback? onArrowLeft,
    VoidCallback? onArrowRight,
    VoidCallback? onHome,
    VoidCallback? onEnd,
    VoidCallback? onPageUp,
    VoidCallback? onPageDown,
  }) {
    final shortcuts = <ShortcutActivator, VoidCallback>{};

    if (onEscape != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.escape)] = onEscape;
    }
    if (onEnter != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.enter)] = onEnter;
    }
    if (onSpace != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.space)] = onSpace;
    }
    if (onArrowUp != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowUp)] = onArrowUp;
    }
    if (onArrowDown != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowDown)] =
          onArrowDown;
    }
    if (onArrowLeft != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowLeft)] =
          onArrowLeft;
    }
    if (onArrowRight != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.arrowRight)] =
          onArrowRight;
    }
    if (onHome != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.home)] = onHome;
    }
    if (onEnd != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.end)] = onEnd;
    }
    if (onPageUp != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.pageUp)] = onPageUp;
    }
    if (onPageDown != null) {
      shortcuts[const SingleActivator(LogicalKeyboardKey.pageDown)] =
          onPageDown;
    }

    return shortcuts;
  }
}
