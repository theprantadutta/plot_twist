// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../pages/auth/auth_screen.dart';
// import '../shell/app_shell.dart';
// import 'app_colors.dart';

// // The AuthGuard can now be a much simpler StatelessWidget
// class AuthGuard extends StatelessWidget {
//   const AuthGuard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // We use a StreamBuilder to listen to Firebase's authentication state in real-time.
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // While the connection is being established, show a loading spinner.
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(color: AppColors.auroraPink),
//             ),
//           );
//         }

//         // If the snapshot has data, it means we have a logged-in user.
//         if (snapshot.hasData) {
//           // User is logged in, show the main app shell.
//           return AppShell(
//             isDarkMode:
//                 true, // This should be managed by a theme provider later
//             onThemeChanged: () {},
//             // The logout function is now a simple call to Firebase Auth.
//             onLogout: () => FirebaseAuth.instance.signOut(),
//           );
//         }

//         // If the snapshot has no data, the user is logged out.
//         // Show the authentication screen.
//         return AuthScreen(
//           // The onLoginSuccess callback is no longer needed because the
//           // StreamBuilder automatically handles rebuilding when the auth state changes.
//           onLoginSuccess: () {},
//         );
//       },
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/auth/auth_providers.dart';
import '../pages/auth/auth_screen.dart';
import '../shell/app_shell.dart';
import 'app_colors.dart';

// The AuthGuard is now a ConsumerWidget
class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch our new provider. Riverpod handles all the complexity.
    final authState = ref.watch(authStateChangesProvider);

    // .when() is the perfect way to handle the loading, error, and data states.
    return authState.when(
      // While the initial user state is being determined
      loading: () => const Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.auroraPink),
        ),
      ),
      // If there's an error connecting to Firebase
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Authentication Error: $err",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      // When we have data (either a User object or null)
      data: (user) {
        if (user != null) {
          // User is logged in, show the main app shell.
          // This widget will now correctly preserve its state across hot reloads.
          return AppShell(
            isDarkMode:
                true, // This should still be managed by the AppearanceNotifier
            onThemeChanged: () {},
            onLogout: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                barrierDismissible: true, // Allows tapping outside to dismiss
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Log Out',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    'Are you sure you want to log out of your account?',
                  ),
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (shouldLogout ?? false) {
                try {
                  await FirebaseAuth.instance.signOut();
                  // Optional: Show a snackbar confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      content: Text('Logged out successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: ${e.toString()}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          );
        } else {
          // User is logged out, show the authentication screen.
          return AuthScreen(
            onLoginSuccess: () {
              // This callback is no longer strictly needed but can be left empty.
              // The StreamProvider handles the navigation automatically.
            },
          );
        }
      },
    );
  }
}
