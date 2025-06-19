// lib/presentation/pages/auth/auth_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/auth/auth_repository.dart';
import '../../../data/core/api_constants.dart';
import '../../core/app_colors.dart';

enum AuthStatus { idle, loading, requiresApproval, success, error }

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

// MAKE THE STATE LIFECYCLE-AWARE
class _AuthScreenState extends State<AuthScreen> with WidgetsBindingObserver {
  final AuthRepository _authRepository = AuthRepository();

  AuthStatus _status = AuthStatus.idle;
  String? _requestToken;
  String _errorMessage = '';

  // ADD THIS LIFECYCLE SETUP
  @override
  void initState() {
    super.initState();
    // Start listening to app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  // ADD THIS LIFECYCLE CLEANUP
  @override
  void dispose() {
    // Stop listening to app lifecycle events
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // THIS IS THE MAGIC!
  // This method is called whenever the app's state changes (e.g., resumed, paused)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // If the app is resumed AND we were waiting for the user to approve the token...
    if (state == AppLifecycleState.resumed &&
        _status == AuthStatus.requiresApproval) {
      // ...then automatically try to complete the login process.
      print("App resumed, automatically trying to complete login...");
      _completeLogin();
    }
  }

  Future<void> _initiateLogin() async {
    setState(() {
      _status = AuthStatus.loading;
      _errorMessage = '';
    });

    final token = await _authRepository.createRequestToken();
    if (token != null) {
      setState(() => _requestToken = token);
      // After getting the token, immediately try to open the URL
      await _openTmdbForApproval();
    } else {
      setState(() {
        _status = AuthStatus.error;
        _errorMessage = "Could not connect to TMDB. Please try again later.";
      });
    }
  }

  Future<void> _openTmdbForApproval() async {
    if (_requestToken == null) return;
    final url = Uri.parse(ApiConstants.tmdbAuthUrl(_requestToken!));

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      // Once the URL is launched, we change the status to wait for approval
      setState(() => _status = AuthStatus.requiresApproval);
    } else {
      setState(() {
        _status = AuthStatus.error;
        _errorMessage = "Could not open browser for authentication.";
      });
    }
  }

  Future<void> _completeLogin() async {
    if (_requestToken == null) return;

    // Prevent multiple calls if already loading
    if (_status == AuthStatus.loading) return;

    setState(() => _status = AuthStatus.loading);

    final success = await _authRepository.createSession(_requestToken!);
    if (success && mounted) {
      setState(() => _status = AuthStatus.success);
      widget.onLoginSuccess();
    } else if (mounted) {
      setState(() {
        _status = AuthStatus.error;
        _errorMessage =
            "Authentication failed. Please ensure you approved the request and try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/auth_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 120),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color:
                                (isDark
                                        ? AppColors.darkSurface
                                        : AppColors.lightSurface)
                                    .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildAuthView(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthView() {
    switch (_status) {
      case AuthStatus.loading:
        return const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(color: AppColors.auroraPink),
        );

      case AuthStatus.requiresApproval:
        return Column(
          key: const ValueKey('approval'),
          children: [
            const Icon(Icons.touch_app_rounded, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            const Text(
              "Waiting for Approval",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Please approve the request in your browser, then return to the app.",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // The user can still manually press this if something goes wrong
            TextButton(
              onPressed: _completeLogin,
              child: const Text(
                'I have approved, Complete Login',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );

      case AuthStatus.error:
        return Column(
          key: const ValueKey('error'),
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.darkErrorRed,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GradientButton(text: 'Try Again', onPressed: _initiateLogin),
          ],
        );

      case AuthStatus.idle:
      case AuthStatus.success:
        return Column(
          key: const ValueKey('idle'),
          children: [
            const Text(
              "Welcome to PlotTwists",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "The best place to track your favorite movies and shows.",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(text: 'Login with TMDB', onPressed: _initiateLogin),
          ],
        );
    }
  }
}

// Reusable gradient button
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const GradientButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.auroraGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.auroraPink.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
