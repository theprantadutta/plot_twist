import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_animations.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../create_custom_list_screen.dart';

/// Widget for managing list collaboration features
class CollaborationWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> customList;
  final CustomListTheme theme;

  const CollaborationWidget({
    super.key,
    required this.customList,
    required this.theme,
  });

  @override
  ConsumerState<CollaborationWidget> createState() =>
      _CollaborationWidgetState();
}

class _CollaborationWidgetState extends ConsumerState<CollaborationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _inviteController = TextEditingController();
  bool _isPublic = false;
  bool _allowEditing = true;
  bool _allowAdding = true;
  bool _allowRemoving = false;

  // Mock collaborators data
  final List<Map<String, dynamic>> _collaborators = [
    {
      'id': 1,
      'name': 'Sarah Johnson',
      'email': 'sarah@example.com',
      'avatar': 'SJ',
      'role': 'Editor',
      'joined': '2024-01-15',
      'status': 'active',
    },
    {
      'id': 2,
      'name': 'Mike Chen',
      'email': 'mike@example.com',
      'avatar': 'MC',
      'role': 'Viewer',
      'joined': '2024-01-10',
      'status': 'active',
    },
    {
      'id': 3,
      'name': 'Emma Wilson',
      'email': 'emma@example.com',
      'avatar': 'EW',
      'role': 'Editor',
      'joined': '2024-01-08',
      'status': 'pending',
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
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
                          _buildInviteSection(),
                          const SizedBox(height: 24),
                          _buildPermissionsSection(),
                          const SizedBox(height: 24),
                          _buildCollaboratorsSection(),
                          const SizedBox(height: 24),
                          _buildPublicSharingSection(),
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
                  Icons.people_rounded,
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
                      'Collaborate',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Invite others to help curate your list',
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

  Widget _buildInviteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invite Collaborators',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Invite Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.darkTextTertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inviteController,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter email address...',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.darkTextTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: _sendInvite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Invite',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Quick Invite Options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickInviteChip('Copy Invite Link', Icons.link_rounded),
            _buildQuickInviteChip('Share via Message', Icons.message_rounded),
            _buildQuickInviteChip('Generate QR Code', Icons.qr_code_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickInviteChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () => _handleQuickInvite(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.theme.primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: widget.theme.primaryColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: widget.theme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Collaboration Permissions',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildPermissionToggle(
                'Allow Editing',
                'Collaborators can modify list details',
                _allowEditing,
                (value) => setState(() => _allowEditing = value),
              ),
              const SizedBox(height: 16),
              _buildPermissionToggle(
                'Allow Adding Items',
                'Collaborators can add new movies/shows',
                _allowAdding,
                (value) => setState(() => _allowAdding = value),
              ),
              const SizedBox(height: 16),
              _buildPermissionToggle(
                'Allow Removing Items',
                'Collaborators can remove items from list',
                _allowRemoving,
                (value) => setState(() => _allowRemoving = value),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionToggle(
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

  Widget _buildCollaboratorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Collaborators (${_collaborators.length})',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: _manageCollaborators,
              child: Text(
                'Manage All',
                style: AppTypography.labelLarge.copyWith(
                  color: widget.theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Collaborators List
        ...List.generate(_collaborators.length, (index) {
          final collaborator = _collaborators[index];

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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: collaborator['status'] == 'pending'
                      ? AppColors.cinematicGold.withValues(alpha: 0.3)
                      : AppColors.darkTextTertiary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.theme.primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        collaborator['avatar'],
                        style: AppTypography.titleMedium.copyWith(
                          color: widget.theme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              collaborator['name'],
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (collaborator['status'] == 'pending')
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cinematicGold.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pending',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.cinematicGold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          collaborator['email'],
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${collaborator['role']} • Joined ${_formatDate(collaborator['joined'])}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.darkTextSecondary,
                    ),
                    color: AppColors.darkSurface,
                    onSelected: (value) =>
                        _handleCollaboratorAction(collaborator, value),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'change_role',
                        child: Text(
                          'Change Role',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                      ),
                      if (collaborator['status'] == 'pending')
                        PopupMenuItem(
                          value: 'resend_invite',
                          child: Text(
                            'Resend Invite',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Text(
                          'Remove',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.cinematicRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPublicSharingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Public Sharing',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make List Public',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Anyone with the link can view this list',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                    activeColor: widget.theme.primaryColor,
                    activeTrackColor: widget.theme.primaryColor.withValues(
                      alpha: 0.3,
                    ),
                    inactiveThumbColor: AppColors.darkTextTertiary,
                    inactiveTrackColor: AppColors.darkBackground,
                  ),
                ],
              ),

              if (_isPublic) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'https://plottwists.app/list/${widget.customList['id']}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextSecondary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _copyPublicLink,
                        icon: Icon(
                          Icons.copy_rounded,
                          color: widget.theme.primaryColor,
                          size: 20,
                        ),
                        tooltip: 'Copy Link',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _sendInvite() {
    final email = _inviteController.text.trim();
    if (email.isEmpty) return;

    HapticFeedback.lightImpact();
    _inviteController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invitation sent to $email'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleQuickInvite(String type) {
    HapticFeedback.selectionClick();

    String message;
    switch (type) {
      case 'Copy Invite Link':
        Clipboard.setData(
          ClipboardData(
            text: 'https://plottwists.app/invite/${widget.customList['id']}',
          ),
        );
        message = 'Invite link copied to clipboard!';
        break;
      case 'Share via Message':
        message = 'Opening message app...';
        break;
      case 'Generate QR Code':
        message = 'QR code generated!';
        break;
      default:
        message = 'Action completed!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _manageCollaborators() {
    // TODO: Navigate to full collaborators management screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening collaborators management...'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleCollaboratorAction(
    Map<String, dynamic> collaborator,
    String action,
  ) {
    HapticFeedback.lightImpact();

    String message;
    switch (action) {
      case 'change_role':
        message = 'Role changed for ${collaborator['name']}';
        break;
      case 'resend_invite':
        message = 'Invite resent to ${collaborator['name']}';
        break;
      case 'remove':
        message = '${collaborator['name']} removed from list';
        break;
      default:
        message = 'Action completed';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _copyPublicLink() {
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
            Text('Public link copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'today';
      } else if (difference == 1) {
        return 'yesterday';
      } else if (difference < 30) {
        return '$difference days ago';
      } else {
        final months = (difference / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
