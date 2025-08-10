import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../core/app_animations.dart';
import 'widgets/theme_selection_widget.dart';
import 'widgets/list_preview_widget.dart';

/// Custom list creation screen with theme selection and visual previews
class CreateCustomListScreen extends ConsumerStatefulWidget {
  const CreateCustomListScreen({super.key});

  @override
  ConsumerState<CreateCustomListScreen> createState() =>
      _CreateCustomListScreenState();
}

class _CreateCustomListScreenState extends ConsumerState<CreateCustomListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _previewAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _previewScaleAnimation;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  String _selectedTheme = 'cinematic';
  bool _isFormValid = false;
  bool _isCreating = false;
  bool _showPreview = false;

  // Available themes for custom lists
  final List<CustomListTheme> _themes = [
    CustomListTheme(
      id: 'cinematic',
      name: 'Cinematic Gold',
      primaryColor: AppColors.cinematicGold,
      secondaryColor: AppColors.cinematicRed,
      gradient: LinearGradient(
        colors: [AppColors.cinematicGold, AppColors.cinematicRed],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Classic movie theater vibes',
    ),
    CustomListTheme(
      id: 'neon',
      name: 'Neon Dreams',
      primaryColor: AppColors.cinematicPurple,
      secondaryColor: AppColors.cinematicBlue,
      gradient: LinearGradient(
        colors: [AppColors.cinematicPurple, AppColors.cinematicBlue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Futuristic and vibrant',
    ),
    CustomListTheme(
      id: 'noir',
      name: 'Film Noir',
      primaryColor: Colors.white,
      secondaryColor: Colors.grey.shade400,
      gradient: LinearGradient(
        colors: [Colors.white, Colors.grey.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Classic black and white',
    ),
    CustomListTheme(
      id: 'sunset',
      name: 'Sunset Boulevard',
      primaryColor: Colors.orange.shade400,
      secondaryColor: Colors.pink.shade400,
      gradient: LinearGradient(
        colors: [Colors.orange.shade400, Colors.pink.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Warm and inviting',
    ),
    CustomListTheme(
      id: 'forest',
      name: 'Emerald Forest',
      primaryColor: Colors.green.shade400,
      secondaryColor: Colors.teal.shade400,
      gradient: LinearGradient(
        colors: [Colors.green.shade400, Colors.teal.shade400],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      description: 'Natural and calming',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupFormListeners();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _previewAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: MotionPresets.slideUp.curve,
          ),
        );

    _previewScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _previewAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _setupFormListeners() {
    _nameController.addListener(_validateForm);
    _descriptionController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        _nameController.text.trim().isNotEmpty &&
        _nameController.text.trim().length >= 3;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });

      if (isValid && !_showPreview) {
        setState(() {
          _showPreview = true;
        });
        _previewAnimationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _previewAnimationController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(child: _buildHeaderSection()),

                    // Form Section
                    SliverToBoxAdapter(child: _buildFormSection()),

                    // Theme Selection Section
                    SliverToBoxAdapter(child: _buildThemeSelectionSection()),

                    // Preview Section
                    if (_showPreview)
                      SliverToBoxAdapter(child: _buildPreviewSection()),

                    // Create Button Section
                    SliverToBoxAdapter(child: _buildCreateButtonSection()),

                    // Bottom Padding
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.darkTextPrimary),
      ),
      title: Text(
        'Create Custom List',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_isFormValid)
          TextButton(
            onPressed: _isCreating ? null : _createList,
            child: Text(
              'Create',
              style: AppTypography.labelLarge.copyWith(
                color: _isCreating
                    ? AppColors.darkTextTertiary
                    : AppColors.cinematicGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Curate Your Collection',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a personalized list with your own theme and style. Share your cinematic taste with the world.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.darkTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'List Details',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          // List Name Field
          _buildTextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            label: 'List Name',
            hint: 'e.g., "My Favorite Sci-Fi Movies"',
            maxLength: 50,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a list name';
              }
              if (value.trim().length < 3) {
                return 'List name must be at least 3 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // List Description Field
          _buildTextFormField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            label: 'Description (Optional)',
            hint: 'Tell others what makes this list special...',
            maxLines: 3,
            maxLength: 200,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          validator: validator,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.darkTextTertiary,
            ),
            filled: true,
            fillColor: AppColors.darkBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getSelectedTheme().primaryColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cinematicRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.cinematicRed, width: 2),
            ),
            counterStyle: AppTypography.labelSmall.copyWith(
              color: AppColors.darkTextTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelectionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Theme',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a visual theme that represents your list\'s personality',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ThemeSelectionWidget(
            themes: _themes,
            selectedTheme: _selectedTheme,
            onThemeSelected: (themeId) {
              setState(() {
                _selectedTheme = themeId;
              });
              HapticFeedback.selectionClick();

              // Trigger preview animation
              if (_showPreview) {
                _previewAnimationController.reset();
                _previewAnimationController.forward();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return AnimatedBuilder(
      animation: _previewAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _previewScaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'See how your list will look',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ListPreviewWidget(
                  name: _nameController.text.trim().isEmpty
                      ? 'Your List Name'
                      : _nameController.text.trim(),
                  description: _descriptionController.text.trim().isEmpty
                      ? 'Your list description will appear here'
                      : _descriptionController.text.trim(),
                  theme: _getSelectedTheme(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateButtonSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: ElevatedButton(
          onPressed: _isFormValid && !_isCreating ? _createList : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isFormValid
                ? _getSelectedTheme().primaryColor
                : AppColors.darkTextTertiary,
            foregroundColor: _isFormValid ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: _isFormValid ? 4 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isCreating) ...[
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isFormValid ? Colors.black : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                _isCreating ? 'Creating List...' : 'Create List',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  CustomListTheme _getSelectedTheme() {
    return _themes.firstWhere(
      (theme) => theme.id == _selectedTheme,
      orElse: () => _themes.first,
    );
  }

  void _createList() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isCreating = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual list creation logic
      final listData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'theme': _selectedTheme,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Show success feedback
      HapticFeedback.lightImpact();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.darkSuccessGreen,
                ),
                const SizedBox(width: 12),
                Text(
                  'List "${_nameController.text.trim()}" created successfully!',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.darkSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back with result
        Navigator.pop(context, listData);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: AppColors.cinematicRed),
                const SizedBox(width: 12),
                Text(
                  'Failed to create list. Please try again.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.darkSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}

/// Custom list theme data model
class CustomListTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final LinearGradient gradient;
  final String description;

  const CustomListTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradient,
    required this.description,
  });
}
