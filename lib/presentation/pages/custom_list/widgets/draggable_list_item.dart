import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../create_custom_list_screen.dart';

/// Draggable list item widget for custom lists with reordering support
class DraggableListItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final CustomListTheme theme;
  final bool isEditMode;
  final bool isGridView;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final Function(int oldIndex, int newIndex)? onReorder;

  const DraggableListItem({
    super.key,
    required this.item,
    required this.theme,
    required this.isEditMode,
    required this.isGridView,
    required this.onTap,
    required this.onRemove,
    this.onReorder,
  });

  @override
  State<DraggableListItem> createState() => _DraggableListItemState();
}

class _DraggableListItemState extends State<DraggableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditMode && widget.onReorder != null) {
      return _buildDraggableItem();
    } else {
      return _buildRegularItem();
    }
  }

  Widget _buildDraggableItem() {
    return LongPressDraggable<Map<String, dynamic>>(
      data: widget.item,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: SizedBox(
            width: widget.isGridView ? 160 : 300,
            child: _buildItemContent(isDragging: true),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: _buildItemContent()),
      onDragStarted: () {
        HapticFeedback.mediumImpact();
      },
      child: _buildItemContent(),
    );
  }

  Widget _buildRegularItem() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildItemContent(),
          );
        },
      ),
    );
  }

  Widget _buildItemContent({bool isDragging = false}) {
    if (widget.isGridView) {
      return _buildGridItem(isDragging: isDragging);
    } else {
      return _buildListItem(isDragging: isDragging);
    }
  }

  Widget _buildGridItem({bool isDragging = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isDragging
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.theme.primaryColor.withValues(alpha: 0.3),
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: widget.theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Stack(
        children: [
          // Main Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poster Area
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.theme.primaryColor.withValues(alpha: 0.3),
                        widget.theme.secondaryColor.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Poster Placeholder
                      Center(
                        child: Icon(
                          widget.item['type'] == 'movie'
                              ? Icons.movie_rounded
                              : Icons.tv_rounded,
                          color: widget.theme.primaryColor.withValues(
                            alpha: 0.7,
                          ),
                          size: 48,
                        ),
                      ),

                      // Rating Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground.withValues(
                              alpha: 0.8,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.cinematicGold,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.item['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.darkTextPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info Section
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item['title'] ?? 'Unknown Title',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.darkTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.item['year'] ?? 'Unknown'} • ${widget.item['genre'] ?? 'Unknown'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (widget.isEditMode)
                        Row(
                          children: [
                            Icon(
                              Icons.drag_handle_rounded,
                              color: AppColors.darkTextTertiary,
                              size: 16,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: widget.onRemove,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.cinematicRed.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.remove_rounded,
                                  color: AppColors.cinematicRed,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Selection Overlay (Edit Mode)
          if (widget.isEditMode)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.theme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListItem({bool isDragging = false}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: isDragging
            ? AppColors.darkSurface.withValues(alpha: 0.9)
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.theme.primaryColor.withValues(alpha: 0.3),
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                  color: widget.theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        children: [
          // Main Content
          Row(
            children: [
              // Poster Area
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.theme.primaryColor.withValues(alpha: 0.3),
                      widget.theme.secondaryColor.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.item['type'] == 'movie'
                        ? Icons.movie_rounded
                        : Icons.tv_rounded,
                    color: widget.theme.primaryColor.withValues(alpha: 0.7),
                    size: 32,
                  ),
                ),
              ),

              // Info Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item['title'] ?? 'Unknown Title',
                              style: AppTypography.titleMedium.copyWith(
                                color: AppColors.darkTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.theme.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: widget.theme.primaryColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.item['rating']?.toStringAsFixed(1) ?? '0.0'}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: widget.theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.item['year'] ?? 'Unknown'} • ${widget.item['genre'] ?? 'Unknown'}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (widget.isEditMode)
                        Row(
                          children: [
                            Icon(
                              Icons.drag_handle_rounded,
                              color: AppColors.darkTextTertiary,
                              size: 20,
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: widget.onRemove,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.cinematicRed.withValues(
                                    alpha: 0.2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.remove_rounded,
                                  color: AppColors.cinematicRed,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Added ${_formatDate(widget.item['added_date'])}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkTextTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Selection Overlay (Edit Mode)
          if (widget.isEditMode)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.theme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
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
      } else if (difference < 7) {
        return '$difference days ago';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      } else {
        final months = (difference / 30).floor();
        return months == 1 ? '1 month ago' : '$months months ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
