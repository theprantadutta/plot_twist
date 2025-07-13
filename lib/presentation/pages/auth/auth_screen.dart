import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../data/firestore/firestore_service.dart';
import '../../core/app_colors.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/forgot_password_dialog.dart';
import 'widgets/social_login_button.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const AuthScreen({super.key, required this.onLoginSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance
    ..initialize(serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']);

  // Keys for form validation
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // All text editing controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupFullNameController = TextEditingController();
  final _signupUsernameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  // UI state variables
  bool _isLoginView = true;
  bool _isLoading = false;
  bool _isSocialLoading = false;
  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _obscureSignupConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFullNameController.dispose();
    _signupUsernameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.darkErrorRed),
    );
  }

  Future<void> _login() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text.trim(),
      );
      if (mounted) widget.onLoginSuccess();
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'An unknown login error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signup() async {
    if (!_signupFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text.trim(),
      );
      if (cred.user != null) {
        // Now also saving the full name
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'fullName': _signupFullNameController.text.trim(),
          'username': _signupUsernameController.text.trim(),
          'email': _signupEmailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        // After creating the user, also set their default notification preferences
        await FirestoreService().updateNotificationSettings({
          'allNotificationsEnabled': true,
          'moviePremiereReminders': false,
          'movieReminderTime': 1,
          'newEpisodeReminders': false,
          'trendingReminders': true,
          'suggestionReminders': true,
          'dailyMovieMarathon': false, // Off by default
          'dailyTvPick': false, // Off by default
        });
        if (mounted) widget.onLoginSuccess();
      }
    } on FirebaseAuthException catch (e) {
      _showErrorSnackBar(e.message ?? 'An unknown sign-up error occurred.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isSocialLoading) return;
    setState(() => _isSocialLoading = true);

    try {
      // Use .authenticate() as per the new documentation for interactive sign-in
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final GoogleSignInClientAuthorization authorization = await googleUser
          .authorizationClient
          .authorizeScopes(['email', 'profile']);
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Sign in with Google failed. No user returned.');
      }

      final userDocRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        // New user, create their document
        await userDocRef.set({
          'fullName': user.displayName ?? 'Google User',
          'username':
              user.email?.split('@').first ??
              'google_user_${user.uid.substring(0, 5)}',
          'email': user.email ?? '',
          'avatarUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // After creating the user, set their default notification preferences
        await FirestoreService().updateNotificationSettings({
          'allNotificationsEnabled': true,
          'moviePremiereReminders': false,
          'movieReminderTime': 1,
          'newEpisodeReminders': false,
          'trendingReminders': true,
          'suggestionReminders': true,
          'dailyMovieMarathon': false, // Off by default
          'dailyTvPick': false, // Off by default
        });
      }

      // The AuthGuard will handle navigation automatically. No need for any navigation logic here.
      // If we reach this point, the authStateChanges stream will fire and AuthGuard will do its job.
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Google Sign-In error: $e');
      _showErrorSnackBar(e.message ?? 'Google Sign-In failed.');
    } catch (e) {
      if (kDebugMode) print('Google Sign-In error: $e');
      _showErrorSnackBar('An unexpected error occurred during Google Sign-In.');
    } finally {
      if (mounted) {
        setState(() => _isSocialLoading = false);
      }
    }
  }

  // --- BUILD METHOD & UI WIDGETS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/auth_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().fadeIn(duration: 1500.ms),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 150)
                      .animate()
                      .fade(delay: 200.ms, duration: 500.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 32),
                  ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildAuthToggleSwitch(),
                                const SizedBox(height: 24),
                                // The improved, flicker-free AnimatedSwitcher
                                AnimatedSwitcher(
                                  duration: 400.ms,
                                  switchInCurve: Curves.easeInOut,
                                  switchOutCurve: Curves.easeInOut,
                                  transitionBuilder: (child, animation) {
                                    // This combines a fade with a size animation for a smooth transition
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        axis: Axis.vertical,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _isLoginView
                                      ? _buildLoginForm()
                                      : _buildSignupForm(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate(delay: 400.ms)
                      .fadeIn()
                      .slideY(begin: 0.1, curve: Curves.easeOut),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildToggleOption("Login", true),
          _buildToggleOption("Sign Up", false),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String title, bool isLogin) {
    bool isSelected = (_isLoginView == isLogin);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLoginView = isLogin),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.auroraGradient : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(isSelected ? 1.0 : 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        key: const ValueKey('login_form'),
        children: [
          AuthTextField(
            controller: _loginEmailController,
            hintText: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _loginPasswordController,
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureLoginPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(
                () => _obscureLoginPassword = !_obscureLoginPassword,
              ),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'Password must be at least 6 characters'
                : null,
          ),
          const SizedBox(height: 16),
          AuthButton(text: 'Login', onPressed: _login, isLoading: _isLoading),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              // Show our new, beautiful dialog
              showDialog(
                context: context,
                builder: (context) => const ForgotPasswordDialog(),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Or login with',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialLoginButton(
                icon: FontAwesomeIcons.google,
                onPressed: _handleGoogleSignIn,
                iconColor: Colors.white,
              ),
              const SizedBox(width: 24),
              SocialLoginButton(
                icon: FontAwesomeIcons.apple,
                onPressed: () =>
                    _showErrorSnackBar('Apple Sign-In not yet implemented'),
                iconColor: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        key: const ValueKey('signup_form'),
        children: [
          AuthTextField(
            controller: _signupFullNameController,
            hintText: 'Full Name',
            icon: Icons.badge_outlined,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter your full name' : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _signupUsernameController,
            hintText: 'Username',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Please enter a username' : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _signupEmailController,
            hintText: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _signupPasswordController,
            hintText: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureSignupPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignupPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(
                () => _obscureSignupPassword = !_obscureSignupPassword,
              ),
            ),
            validator: (v) => (v == null || v.length < 6)
                ? 'Password must be at least 6 characters'
                : null,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _signupConfirmPasswordController,
            hintText: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureSignupConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignupConfirmPassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white70,
              ),
              onPressed: () => setState(
                () => _obscureSignupConfirmPassword =
                    !_obscureSignupConfirmPassword,
              ),
            ),
            validator: (v) {
              if (v != _signupPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: 'Create Account',
            onPressed: _signup,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
