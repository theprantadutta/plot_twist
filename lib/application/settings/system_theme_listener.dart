import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'appearance_provider.dart';

part 'system_theme_listener.g.dart';

/// Service that listens to system theme changes and updates app theme accordingly
class SystemThemeListener {
  final Ref _ref;
  Brightness? _lastSystemBrightness;

  SystemThemeListener(this._ref);

  /// Initialize the listener with current system brightness
  void initialize(BuildContext context) {
    _lastSystemBrightness = MediaQuery.of(context).platformBrightness;
  }

  /// Check for system theme changes and update if necessary
  void checkForSystemThemeChange(BuildContext context) {
    final currentSystemBrightness = MediaQuery.of(context).platformBrightness;
    final appearanceState = _ref.read(appearanceNotifierProvider);

    // Only react to system changes if user has selected system theme mode
    if (appearanceState.themeMode == ThemeMode.system &&
        _lastSystemBrightness != null &&
        _lastSystemBrightness != currentSystemBrightness) {
      // System theme changed, update our state
      _ref
          .read(appearanceNotifierProvider.notifier)
          .handleSystemThemeChange(context);

      _lastSystemBrightness = currentSystemBrightness;
    }

    // First time initialization
    _lastSystemBrightness ??= currentSystemBrightness;
  }

  /// Force update system brightness tracking
  void updateSystemBrightness(BuildContext context) {
    _lastSystemBrightness = MediaQuery.of(context).platformBrightness;
  }
}

/// Provider for the system theme listener
@riverpod
SystemThemeListener systemThemeListener(Ref ref) {
  return SystemThemeListener(ref);
}

/// Widget that automatically listens to system theme changes
class SystemThemeListenerWidget extends ConsumerStatefulWidget {
  final Widget child;

  const SystemThemeListenerWidget({super.key, required this.child});

  @override
  ConsumerState<SystemThemeListenerWidget> createState() =>
      _SystemThemeListenerWidgetState();
}

class _SystemThemeListenerWidgetState
    extends ConsumerState<SystemThemeListenerWidget>
    with WidgetsBindingObserver {
  late SystemThemeListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = ref.read(systemThemeListenerProvider);
    WidgetsBinding.instance.addObserver(this);

    // Initialize after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _listener.initialize(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      _listener.checkForSystemThemeChange(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Check for theme changes when app becomes active
    if (state == AppLifecycleState.resumed && mounted) {
      _listener.checkForSystemThemeChange(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check for theme changes on every build (in case MediaQuery changes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _listener.checkForSystemThemeChange(context);
      }
    });

    return widget.child;
  }
}

/// Mixin that provides system theme listening capabilities to any widget
mixin SystemThemeListenerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, WidgetsBindingObserver {
  late SystemThemeListener _systemThemeListener;

  @override
  void initState() {
    super.initState();
    _systemThemeListener = ref.read(systemThemeListenerProvider);
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _systemThemeListener.initialize(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) {
      _systemThemeListener.checkForSystemThemeChange(context);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && mounted) {
      _systemThemeListener.checkForSystemThemeChange(context);
    }
  }
}
