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
import 'presentation/core/app_colors.dart';
import 'presentation/core/app_entry.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the persistence service
  final persistenceService = PersistenceService();
  await persistenceService.init();

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
    // Theme definitions remain here as they are an app-level concern.
    final appearanceState = ref.watch(appearanceProvider);
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: appearanceState.useTrueBlack
          ? Colors.black
          : AppColors.darkBackground,
      primaryColor: appearanceState.accentColor, // Dynamic Accent Color
      colorScheme: ColorScheme.dark(
        primary: appearanceState.accentColor, // Dynamic Accent Color
        secondary: AppColors.auroraPurple,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkTextPrimary,
        onSecondary: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.darkErrorRed,
        onError: AppColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
      ),
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: appearanceState.accentColor, // Dynamic Accent Color
      colorScheme: ColorScheme.light(
        primary: appearanceState.accentColor, // Dynamic Accent Color
        secondary: AppColors.auroraPurple,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.lightErrorRed,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
        bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
      ),
    );

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Plot Twists',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appearanceState.themeMode,
      debugShowCheckedModeBanner: false,
      // home: AppShell(isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme),
      home: const AppEntry(),
    );
  }
}
