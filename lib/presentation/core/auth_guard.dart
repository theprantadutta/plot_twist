import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/auth/auth_screen.dart';
import '../shell/app_shell.dart';
import 'app_colors.dart';

// The AuthGuard can now be a much simpler StatelessWidget
class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a StreamBuilder to listen to Firebase's authentication state in real-time.
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the connection is being established, show a loading spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.auroraPink),
            ),
          );
        }

        // If the snapshot has data, it means we have a logged-in user.
        if (snapshot.hasData) {
          // User is logged in, show the main app shell.
          return AppShell(
            isDarkMode:
                true, // This should be managed by a theme provider later
            onThemeChanged: () {},
            // The logout function is now a simple call to Firebase Auth.
            onLogout: () => FirebaseAuth.instance.signOut(),
          );
        }

        // If the snapshot has no data, the user is logged out.
        // Show the authentication screen.
        return AuthScreen(
          // The onLoginSuccess callback is no longer needed because the
          // StreamBuilder automatically handles rebuilding when the auth state changes.
          onLoginSuccess: () {},
        );
      },
    );
  }
}
