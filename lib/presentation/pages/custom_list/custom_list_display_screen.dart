import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_colors.dart';
import '../../core/app_typography.dart';
import '../../core/app_animations.dart';
import 'create_custom_list_screen.dart';
import 'widgets/draggable_list_item.dart';
import 'widgets/empty_list_state.dart';

/// Custom list display screen with hero section and management features
class CustomListDisplayScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> customList;

  const CustomListDisplayScreen({super.key, required this.customList});

  @override
  ConsumerState<CustomListDisplayScreen> createState() =>
      _CustomListDisplayScreenState();
}

class _CustomListDisplayScreenState
    extends ConsumerState<CustomListDisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _heroFadeAnimation;
  late Animation<Offset> _heroSlideAnimation;
  late Animation<double> _listFadeAnimation;

  bool _isGridView = true;
  bool _isEditMode = false;
  final bool _isReordering = false;
  List<Map<String, dynamic>> _listItems = [];
  CustomListTheme? _currentTheme;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadListData();
    _heroAnimationController.forward();
  }

  void _setupAnimations() {
    _heroAnimationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _heroFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroAnimationController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _heroSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _heroAnimationController,
            curve: MotionPresets.slideUp.curve,
          ),
        );

    _listFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _listAnimationController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );
  }

  void _loadListData() {
    // Load theme data
    final themeId = widget.customList['theme'] as String? ?? 'cinematic';
    _currentTheme = _getThemeById(themeId);

    // Mock list items - in real app, this would come from API/database
    _listItems = [
      {
        'id': 1,
        'title': 'The Dark Knight',
        'year': 2008,
        'type': 'movie',
        'poster_path': '/poster1.jpg',
        'rating': 9.0,
        'genre': 'Action',
        'added_date': '2024-01-15',
      },
      {
        'id': 2,
        'title': 'Inception',
        'year': 2010,
        'type': 'movie',
        'poster_path': '/poster2.jpg',
        'rating': 8.8,
        'genre': 'Sci-Fi',
        'added_date': '2024-01-14',
      },
      {
        'id': 3,
        'title': 'Breaking Bad',
        'year': 2008,
        'type': 'tv',
        'poster_path': '/poster3.jpg',
        'rating': 9.5,
        'genre': 'Drama',
        'added_date': '2024-01-13',
      },
      {
        'id': 4,
        'title': 'Interstellar',
        'year': 2014,
        'type': 'movie',
        'poster_path': '/poster4.jpg',
        'rating': 8.6,
        'genre': 'Sci-Fi',
        'added_date': '2024-01-12',
      },
      {
        'id': 5,
        'title': 'The Godfather',
        'year': 1972,
        'type': 'movie',
        'poster_path': '/poster5.jpg',
        'rating': 9.2,
        'genre': 'Crime',
        'added_date': '2024-01-11',
      },
    ];

    _listAnimationController.forward();
  }

  CustomListTheme _getThemeById(String themeId) {
    final themes = [
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
      // Add other themes as needed
    ];

    return themes.firstWhere(
      (theme) => theme.id == themeId,
      orElse: () => themes.first,
    );
  }

  @override
  void dispose() {
    _heroAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        slivers: [
          // Hero Section
          SliverToBoxAdapter(child: _buildHeroSection()),

          // Controls Section
          SliverToBoxAdapter(child: _buildControlsSection()),

          // List Content
          if (_listItems.isEmpty)
            SliverToBoxAdapter(
              child: EmptyListState(
                theme: _currentTheme!,
                onAddContent: _addContent,
              ),
            )
          else
            _buildListContent(),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _heroFadeAnimation,
          child: SlideTransition(
            position: _heroSlideAnimation,
            child: Container(
              height: 300,
              decoration: BoxDecoration(gradient: _currentTheme!.gradient),
              child: Stack(
                children: [
                  // Background Pattern
                  Positioned.fill(child: _buildBackgroundPattern()),

                  // Dark Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // App Bar
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: _shareList,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _showMoreOptions,
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80), // Space for app bar
                          // List Stats
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.movie_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_listItems.length} items',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentTheme!.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _currentTheme!.primaryColor
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  _currentTheme!.name,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // List Title and Description
                          Text(
                            widget.customList['name'] ?? 'Untitled List',
                            style: AppTypography.displaySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          if (widget.customList['description'] != null &&
                              widget.customList['description']
                                  .toString()
                                  .isNotEmpty)
                            Text(
                              widget.customList['description'],
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundPattern() {
    return CustomPaint(
      painter: PatternPainter(color: Colors.white.withValues(alpha: 0.1)),
    );
  }

  Widget _buildControlsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // View Toggle
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: _isGridView,
                  onTap: () => _toggleView(true),
                ),
                _buildViewToggleButton(
                  icon: Icons.view_list_rounded,
                  isSelected: !_isGridView,
                  onTap: () => _toggleView(false),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              // Edit Mode Toggle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: TextButton.icon(
                  onPressed: _toggleEditMode,
                  icon: Icon(
                    _isEditMode ? Icons.done_rounded : Icons.edit_rounded,
                    color: _isEditMode
                        ? _currentTheme!.primaryColor
                        : AppColors.darkTextSecondary,
                  ),
                  label: Text(
                    _isEditMode ? 'Done' : 'Edit',
                    style: AppTypography.labelLarge.copyWith(
                      color: _isEditMode
                          ? _currentTheme!.primaryColor
                          : AppColors.darkTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Sort Button
              IconButton(
                onPressed: _showSortOptions,
                icon: Icon(
                  Icons.sort_rounded,
                  color: AppColors.darkTextSecondary,
                ),
                tooltip: 'Sort',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _currentTheme!.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.black : AppColors.darkTextSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildListContent() {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listFadeAnimation,
          child: _isGridView ? _buildGridView() : _buildListView(),
        );
      },
    );
  }

  Widget _buildGridView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = _listItems[index];
          return TweenAnimationBuilder<double>(
            duration:
                MotionPresets.slideUp.duration +
                Duration(milliseconds: index * 100),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: MotionPresets.slideUp.curve,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: DraggableListItem(
              item: item,
              theme: _currentTheme!,
              isEditMode: _isEditMode,
              isGridView: _isGridView,
              onTap: () => _viewItemDetails(item),
              onRemove: () => _removeItem(item),
              onReorder: _isEditMode
                  ? (oldIndex, newIndex) => _reorderItems(oldIndex, newIndex)
                  : null,
            ),
          );
        }, childCount: _listItems.length),
      ),
    );
  }

  Widget _buildListView() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = _listItems[index];
          return TweenAnimationBuilder<double>(
            duration:
                MotionPresets.slideUp.duration +
                Duration(milliseconds: index * 50),
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
              child: DraggableListItem(
                item: item,
                theme: _currentTheme!,
                isEditMode: _isEditMode,
                isGridView: _isGridView,
                onTap: () => _viewItemDetails(item),
                onRemove: () => _removeItem(item),
                onReorder: _isEditMode
                    ? (oldIndex, newIndex) => _reorderItems(oldIndex, newIndex)
                    : null,
              ),
            ),
          );
        }, childCount: _listItems.length),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _addContent,
      backgroundColor: _currentTheme!.primaryColor,
      foregroundColor: Colors.black,
      icon: Icon(Icons.add_rounded),
      label: Text(
        'Add Content',
        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _toggleView(bool isGrid) {
    if (_isGridView != isGrid) {
      setState(() {
        _isGridView = isGrid;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
    HapticFeedback.lightImpact();
  }

  void _reorderItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _listItems.removeAt(oldIndex);
      _listItems.insert(newIndex, item);
    });
    HapticFeedback.selectionClick();
  }

  void _removeItem(Map<String, dynamic> item) {
    setState(() {
      _listItems.removeWhere((listItem) => listItem['id'] == item['id']);
    });
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['title']} removed from list'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: _currentTheme!.primaryColor,
          onPressed: () {
            setState(() {
              _listItems.add(item);
            });
          },
        ),
      ),
    );
  }

  void _addContent() {
    // TODO: Navigate to content search/selection screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add content functionality coming soon!'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewItemDetails(Map<String, dynamic> item) {
    // TODO: Navigate to item detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${item['title']}...'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareList() {
    // TODO: Implement list sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${widget.customList['name']}"...'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMoreOptionsSheet(),
    );
  }

  Widget _buildMoreOptionsSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkTextTertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'List Options',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildOptionItem(
                  icon: Icons.edit_rounded,
                  title: 'Edit List Details',
                  onTap: _editListDetails,
                ),
                _buildOptionItem(
                  icon: Icons.palette_rounded,
                  title: 'Change Theme',
                  onTap: _changeTheme,
                ),
                _buildOptionItem(
                  icon: Icons.download_rounded,
                  title: 'Export List',
                  onTap: _exportList,
                ),
                _buildOptionItem(
                  icon: Icons.people_rounded,
                  title: 'Collaborate',
                  onTap: _collaborateOnList,
                ),
                _buildOptionItem(
                  icon: Icons.delete_rounded,
                  title: 'Delete List',
                  onTap: _deleteList,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.cinematicRed.withValues(alpha: 0.2)
              : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDestructive
              ? AppColors.cinematicRed
              : AppColors.darkTextPrimary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: isDestructive
              ? AppColors.cinematicRed
              : AppColors.darkTextPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkTextTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sort By',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sort Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSortOption('Date Added', Icons.schedule_rounded),
                  _buildSortOption('Title (A-Z)', Icons.sort_by_alpha_rounded),
                  _buildSortOption('Rating', Icons.star_rounded),
                  _buildSortOption('Year', Icons.calendar_today_rounded),
                  _buildSortOption('Custom Order', Icons.reorder_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.darkTextSecondary),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        _sortList(title);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _sortList(String sortType) {
    setState(() {
      switch (sortType) {
        case 'Date Added':
          _listItems.sort((a, b) => b['added_date'].compareTo(a['added_date']));
          break;
        case 'Title (A-Z)':
          _listItems.sort((a, b) => a['title'].compareTo(b['title']));
          break;
        case 'Rating':
          _listItems.sort((a, b) => b['rating'].compareTo(a['rating']));
          break;
        case 'Year':
          _listItems.sort((a, b) => b['year'].compareTo(a['year']));
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sorted by $sortType'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _editListDetails() {
    // TODO: Navigate to edit list screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit list details functionality coming soon!'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _changeTheme() {
    // TODO: Show theme selection dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Change theme functionality coming soon!'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _exportList() {
    // TODO: Implement list export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export list functionality coming soon!'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _collaborateOnList() {
    // TODO: Implement collaboration features
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Collaboration functionality coming soon!'),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          'Delete List',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.customList['name']}"? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('List deleted'),
                  backgroundColor: AppColors.darkSurface,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Text(
              'Delete',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.cinematicRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

/// Custom painter for background pattern
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 20.0;

    // Draw diagonal lines
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
