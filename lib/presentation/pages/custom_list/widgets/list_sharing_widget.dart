import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';
import '../create_custom_list_screen.dart';
import 'list_preview_card.dart';

/// Widget for sharing custom lists with preview generation
class ListSharingWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> customList;
  final List<Map<String, dynamic>> listItems;
  final CustomListTheme theme;

  const ListSharingWidget({
    super.key,
    required this.customList,
    required this.listItems,
    required this.theme,
  });

  @override
  ConsumerState<ListSharingWidget> createState() => _ListSharingWidgetState();
}

class _ListSharingWidgetState extends ConsumerState<ListSharingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedShareFormat = 'social';
  bool _isGeneratingPreview = false;
  bool _includeDescription = true;
  bool _includeStats = true;
  bool _includePosters = true;

  final List<Map<String, String>> _shareFormats = [
    {
      'id': 'social',
      'name': 'Social Media',
      'description': 'Optimized for Instagram, Twitter, Facebook',
      'icon': 'share',
    },
    {
      'id': 'story',
      'name': 'Story Format',
      'description': 'Vertical format for Instagram/Snapchat stories',
      'icon': 'photo',
    },
    {
      'id': 'link',
      'name': 'Share Link',
      'description': 'Generate a shareable link to your list',
      'icon': 'link',
    },
    {
      'id': 'export',
      'name': 'Export Data',
      'description': 'Download as JSON, CSV, or PDF',
      'icon': 'download',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPreviewSection(),
                          const SizedBox(height: 24),
                          _buildShareFormatSection(),
                          const SizedBox(height: 24),
                          _buildCustomizationSection(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.theme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: widget.theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share Your List',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Create beautiful previews and share with friends',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Preview Card
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ListPreviewCard(
            customList: widget.customList,
            listItems: widget.listItems,
            theme: widget.theme,
            format: _selectedShareFormat,
            includeDescription: _includeDescription,
            includeStats: _includeStats,
            includePosters: _includePosters,
          ),
        ),

        const SizedBox(height: 16),

        // Generate Button
        if (_isGeneratingPreview)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Generating preview...',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: _generatePreview,
            icon: Icon(Icons.refresh_rounded),
            label: Text('Regenerate Preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkSurface,
              foregroundColor: AppColors.darkTextPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShareFormatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Format',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Format Options
        ...List.generate(_shareFormats.length, (index) {
          final format = _shareFormats[index];
          final isSelected = format['id'] == _selectedShareFormat;

          return TweenAnimationBuilder<double>(
            duration:
                MotionPresets.slideUp.duration +
                Duration(milliseconds: index * 100),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: MotionPresets.slideUp.curve,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _selectShareFormat(format['id']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.theme.primaryColor.withValues(alpha: 0.1)
                        : AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? widget.theme.primaryColor
                          : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? widget.theme.primaryColor.withValues(alpha: 0.2)
                              : AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForFormat(format['icon']!),
                          color: isSelected
                              ? widget.theme.primaryColor
                              : AppColors.darkTextSecondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              format['name']!,
                              style: AppTypography.titleSmall.copyWith(
                                color: isSelected
                                    ? widget.theme.primaryColor
                                    : AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              format['description']!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: widget.theme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customize Preview',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Customization Options
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildToggleOption(
                'Include Description',
                'Show list description in preview',
                _includeDescription,
                (value) => setState(() => _includeDescription = value),
              ),
              const SizedBox(height: 16),
              _buildToggleOption(
                'Include Stats',
                'Show item count and theme info',
                _includeStats,
                (value) => setState(() => _includeStats = value),
              ),
              const SizedBox(height: 16),
              _buildToggleOption(
                'Include Posters',
                'Show movie/TV show posters',
                _includePosters,
                (value) => setState(() => _includePosters = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: widget.theme.primaryColor,
          activeTrackColor: widget.theme.primaryColor.withValues(alpha: 0.3),
          inactiveThumbColor: AppColors.darkTextTertiary,
          inactiveTrackColor: AppColors.darkBackground,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareList,
            icon: Icon(
              _getIconForFormat(
                _shareFormats.firstWhere(
                  (f) => f['id'] == _selectedShareFormat,
                )['icon']!,
              ),
            ),
            label: Text(_getActionTextForFormat(_selectedShareFormat)),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.theme.primaryColor,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _copyLink,
                icon: Icon(Icons.link_rounded),
                label: Text('Copy Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkTextPrimary,
                  side: BorderSide(
                    color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _saveToGallery,
                icon: Icon(Icons.download_rounded),
                label: Text('Save Image'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkTextPrimary,
                  side: BorderSide(
                    color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getIconForFormat(String iconName) {
    switch (iconName) {
      case 'share':
        return Icons.share_rounded;
      case 'photo':
        return Icons.photo_rounded;
      case 'link':
        return Icons.link_rounded;
      case 'download':
        return Icons.download_rounded;
      default:
        return Icons.share_rounded;
    }
  }

  String _getActionTextForFormat(String format) {
    switch (format) {
      case 'social':
        return 'Share to Social Media';
      case 'story':
        return 'Share to Story';
      case 'link':
        return 'Generate Share Link';
      case 'export':
        return 'Export Data';
      default:
        return 'Share';
    }
  }

  void _selectShareFormat(String formatId) {
    if (formatId != _selectedShareFormat) {
      setState(() {
        _selectedShareFormat = formatId;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _generatePreview() async {
    setState(() {
      _isGeneratingPreview = true;
    });

    // Simulate preview generation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isGeneratingPreview = false;
      });

      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preview updated!'),
          backgroundColor: AppColors.darkSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _shareList() async {
    HapticFeedback.lightImpact();

    // TODO: Implement actual sharing logic based on selected format
    final message =
        'Sharing "${widget.customList['name']}" as $_selectedShareFormat format...';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );

    // Close the sharing widget after a delay
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _copyLink() {
    // TODO: Generate and copy shareable link
    Clipboard.setData(
      ClipboardData(
        text: 'https://plottwists.app/list/${widget.customList['id']}',
      ),
    );

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.darkSuccessGreen),
            const SizedBox(width: 12),
            Text('Link copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _saveToGallery() {
    // TODO: Implement save to gallery functionality
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image saved to gallery!'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
