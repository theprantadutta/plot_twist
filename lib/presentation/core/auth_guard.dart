// lib/presentation/core/auth_guard.dart

import 'package:flutter/material.dart';

import '../../../data/auth/auth_repository.dart'; // Correct path
import '../pages/auth/auth_screen.dart';
import '../shell/app_shell.dart';
import 'app_colors.dart';

class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  final AuthRepository _authRepository = AuthRepository();
  late Future<bool> _hasSessionFuture;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    setState(() {
      _hasSessionFuture = _authRepository.hasSession();
    });
  }

  void _logout() async {
    await _authRepository.deleteSession();
    _checkSession(); // Re-check session status to show login screen
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.auroraPink),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // User is logged in
          return AppShell(
            isDarkMode: true,
            onThemeChanged: () {},
            onLogout: _logout, // Pass the real logout function
          );
        }

        // User is not logged in
        return AuthScreen(
          onLoginSuccess: _checkSession, // Re-check session on login
        );
      },
    );
  }
}
