import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/home/home_providers.dart';
import 'application/services/notification_service.dart';
import 'application/settings/appearance_provider.dart';
import 'data/local/persistence_service.dart';
import 'firebase_options.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/core/app_entry.dart';
import 'presentation/core/performance/performance_integration.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the persistence service
  final persistenceService = PersistenceService();
  await persistenceService.init();

  // --- INITIALIZE PERFORMANCE OPTIMIZATION ---
  await PerformanceIntegration.instance.initialize();
  // ------------------------------------

  // --- INITIALIZE NOTIFICATION SERVICES ---
  NotificationService.init();
  NotificationService.localNotificationInit();
  // ------------------------------------
  dotenv.load();
  runApp(
    ProviderScope(
      overrides: [
        persistenceServiceProvider.overrideWithValue(persistenceService),
      ],
      child: PlotTwistsApp(),
    ),
  );
}

class PlotTwistsApp extends ConsumerWidget {
  const PlotTwistsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceState = ref.watch(appearanceNotifierProvider);

    // Use the enhanced theme system with custom accent color
    final lightTheme = AppTheme.createCustomTheme(
      brightness: Brightness.light,
      primaryColor: appearanceState.accentColor,
      backgroundColor: appearanceState.useTrueBlack ? Colors.black : null,
    );

    final darkTheme = AppTheme.createCustomTheme(
      brightness: Brightness.dark,
      primaryColor: appearanceState.accentColor,
      backgroundColor: appearanceState.useTrueBlack ? Colors.black : null,
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Plot Twists',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appearanceState.themeMode,
      debugShowCheckedModeBanner: false,
      home: const AppEntry(),
      builder: (context, child) {
        // Handle system theme changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref
              .read(appearanceNotifierProvider.notifier)
              .handleSystemThemeChange(context);
        });
        return child!;
      },
    );
  }
}
