import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../create_custom_list_screen.dart';

/// Widget that generates shareable preview cards for custom lists
class ListPreviewCard extends StatelessWidget {
  final Map<String, dynamic> customList;
  final List<Map<String, dynamic>> listItems;
  final CustomListTheme theme;
  final String format;
  final bool includeDescription;
  final bool includeStats;
  final bool includePosters;

  const ListPreviewCard({
    super.key,
    required this.customList,
    required this.listItems,
    required this.theme,
    required this.format,
    this.includeDescription = true,
    this.includeStats = true,
    this.includePosters = true,
  });

  @override
  Widget build(BuildContext context) {
    switch (format) {
      case 'social':
        return _buildSocialMediaCard();
      case 'story':
        return _buildStoryCard();
      case 'link':
        return _buildLinkPreviewCard();
      case 'export':
        return _buildExportPreviewCard();
      default:
        return _buildSocialMediaCard();
    }
  }

  Widget _buildSocialMediaCard() {
    return Container(
      width: 400,
      height: 300,
      decoration: BoxDecoration(
        gradient: theme.gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(child: _buildBackgroundPattern()),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.movie_creation_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'PlotTwists',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (includeStats)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${listItems.length} items',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // List Title
                  Text(
                    customList['name'] ?? 'Untitled List',
                    style: AppTypography.headlineMedium.copyWith(
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

                  if (includeDescription &&
                      customList['description'] != null &&
                      customList['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      customList['description'],
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Poster Row
                  if (includePosters && listItems.isNotEmpty) _buildPosterRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard() {
    return Container(
      width: 300,
      height: 500,
      decoration: BoxDecoration(
        gradient: theme.gradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned.fill(child: _buildBackgroundPattern()),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.movie_creation_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PlotTwists',
                            style: AppTypography.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (includeStats)
                            Text(
                              '${listItems.length} movies & shows',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Poster Grid
                  if (includePosters && listItems.isNotEmpty)
                    _buildPosterGrid(),

                  const SizedBox(height: 24),

                  // List Info
                  Text(
                    customList['name'] ?? 'Untitled List',
                    style: AppTypography.headlineLarge.copyWith(
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
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (includeDescription &&
                      customList['description'] != null &&
                      customList['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      customList['description'],
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
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkPreviewCard() {
    return Container(
      width: 500,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              gradient: theme.gradient,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: _buildBackgroundPattern()),
                Center(
                  child: Icon(
                    Icons.movie_creation_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Site Info
                  Row(
                    children: [
                      Icon(
                        Icons.movie_creation_rounded,
                        color: theme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'plottwists.app',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    customList['name'] ?? 'Untitled List',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (includeDescription &&
                      customList['description'] != null &&
                      customList['description'].toString().isNotEmpty)
                    Text(
                      customList['description'],
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const Spacer(),

                  // Stats
                  if (includeStats)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${listItems.length} items',
                            style: AppTypography.labelSmall.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            theme.name,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.darkTextSecondary,
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
    );
  }

  Widget _buildExportPreviewCard() {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.movie_creation_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'PlotTwists Export',
                  style: AppTypography.titleMedium.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // List Title
            Text(
              customList['name'] ?? 'Untitled List',
              style: AppTypography.headlineMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),

            if (includeDescription &&
                customList['description'] != null &&
                customList['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                customList['description'],
                style: AppTypography.bodyLarge.copyWith(color: Colors.black54),
              ),
            ],

            const SizedBox(height: 24),

            // Stats
            if (includeStats)
              Row(
                children: [
                  _buildStatItem('Items', '${listItems.length}'),
                  const SizedBox(width: 24),
                  _buildStatItem('Theme', theme.name),
                  const SizedBox(width: 24),
                  _buildStatItem(
                    'Created',
                    _formatDate(customList['created_at']),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Items Preview
            Text(
              'Items Preview',
              style: AppTypography.titleMedium.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: listItems.take(5).length,
                itemBuilder: (context, index) {
                  final item = listItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item['title'] ?? 'Unknown Title',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          '${item['year'] ?? 'Unknown'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            if (listItems.length > 5)
              Text(
                '... and ${listItems.length - 5} more items',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterRow() {
    final displayItems = listItems.take(4).toList();

    return Row(
      children: [
        ...displayItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Container(
            width: 40,
            height: 60,
            margin: EdgeInsets.only(
              right: index < displayItems.length - 1 ? 8 : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                item['type'] == 'movie'
                    ? Icons.movie_rounded
                    : Icons.tv_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 20,
              ),
            ),
          );
        }),
        if (listItems.length > 4) ...[
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '+${listItems.length - 4}',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPosterGrid() {
    final displayItems = listItems.take(6).toList();

    return SizedBox(
      height: 120,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                item['type'] == 'movie'
                    ? Icons.movie_rounded
                    : Icons.tv_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundPattern() {
    return CustomPaint(
      painter: PatternPainter(color: Colors.white.withValues(alpha: 0.1)),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
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
