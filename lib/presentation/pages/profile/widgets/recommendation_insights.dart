import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Recommendation insights showing why content was suggested
class RecommendationInsights extends ConsumerStatefulWidget {
  final Map<String, dynamic> userProfile;
  final List<Map<String, dynamic>> recommendations;

  const RecommendationInsights({
    super.key,
    required this.userProfile,
    required this.recommendations,
  });

  @override
  ConsumerState<RecommendationInsights> createState() =>
      _RecommendationInsightsState();
}

class _RecommendationInsightsState extends ConsumerState<RecommendationInsights>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _insightControllers;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedInsightType = 'taste_profile';

  final List<Map<String, String>> _insightTypes = [
    {
      'id': 'taste_profile',
      'name': 'Taste Profile',
      'description': 'Based on your viewing patterns',
      'icon': 'person',
    },
    {
      'id': 'mood_analysis',
      'name': 'Mood Analysis',
      'description': 'Matching your current mood',
      'icon': 'psychology',
    },
    {
      'id': 'social_trends',
      'name': 'Social Trends',
      'description': 'What similar users enjoy',
      'icon': 'group',
    },
    {
      'id': 'discovery_engine',
      'name': 'Discovery Engine',
      'description': 'AI-powered suggestions',
      'icon': 'auto_awesome',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: MotionPresets.fadeIn.duration,
      vsync: this,
    );

    // Create controllers for each insight section
    _insightControllers = List.generate(
      6, // Number of insight sections
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 150)),
        vsync: this,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: MotionPresets.fadeIn.curve,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: MotionPresets.slideUp.curve,
          ),
        );
  }

  void _startAnimations() {
    _animationController.forward();

    // Start insight animations with staggered delays
    Future.delayed(const Duration(milliseconds: 300), () {
      for (int i = 0; i < _insightControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 150), () {
          if (mounted) {
            _insightControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _insightControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInsightTypeTabs(),
                  const SizedBox(height: 24),
                  _buildInsightContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cinematicGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.insights_rounded,
            color: AppColors.cinematicGold,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommendation Insights',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Understanding your personalized suggestions',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _showInsightDetails,
          icon: Icon(
            Icons.help_outline_rounded,
            color: AppColors.cinematicGold,
          ),
          tooltip: 'How recommendations work',
        ),
      ],
    );
  }

  Widget _buildInsightTypeTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_insightTypes.length, (index) {
          final insightType = _insightTypes[index];
          final isSelected = insightType['id'] == _selectedInsightType;

          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 500 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                right: index < _insightTypes.length - 1 ? 12 : 0,
              ),
              child: GestureDetector(
                onTap: () => _selectInsightType(insightType['id']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.cinematicGold.withValues(alpha: 0.2)
                        : AppColors.darkBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.cinematicGold
                          : AppColors.darkTextTertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getIconForInsightType(insightType['icon']!),
                        color: isSelected
                            ? AppColors.cinematicGold
                            : AppColors.darkTextSecondary,
                        size: 20,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        insightType['name']!,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.cinematicGold
                              : AppColors.darkTextSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInsightContent() {
    switch (_selectedInsightType) {
      case 'taste_profile':
        return _buildTasteProfileInsights();
      case 'mood_analysis':
        return _buildMoodAnalysisInsights();
      case 'social_trends':
        return _buildSocialTrendsInsights();
      case 'discovery_engine':
        return _buildDiscoveryEngineInsights();
      default:
        return _buildTasteProfileInsights();
    }
  }

  Widget _buildTasteProfileInsights() {
    return Column(
      children: [
        _buildInsightCard(
          title: 'Your Genre Preferences',
          subtitle: 'Based on 127 movies and shows watched',
          icon: Icons.palette_rounded,
          color: AppColors.cinematicPurple,
          content: _buildGenrePreferences(),
          controller: _insightControllers[0],
        ),
        const SizedBox(height: 20),
        _buildInsightCard(
          title: 'Viewing Patterns',
          subtitle: 'Your typical watching behavior',
          icon: Icons.analytics_rounded,
          color: AppColors.cinematicBlue,
          content: _buildViewingPatterns(),
          controller: _insightControllers[1],
        ),
        const SizedBox(height: 20),
        _buildInsightCard(
          title: 'Rating Tendencies',
          subtitle: 'How you rate different content',
          icon: Icons.star_rounded,
          color: AppColors.cinematicGold,
          content: _buildRatingTendencies(),
          controller: _insightControllers[2],
        ),
      ],
    );
  }

  Widget _buildMoodAnalysisInsights() {
    return Column(
      children: [
        _buildInsightCard(
          title: 'Current Mood Detection',
          subtitle: 'Based on recent activity and time patterns',
          icon: Icons.psychology_rounded,
          color: AppColors.cinematicPurple,
          content: _buildMoodDetection(),
          controller: _insightControllers[0],
        ),
        const SizedBox(height: 20),
        _buildInsightCard(
          title: 'Mood-Based Suggestions',
          subtitle: 'Content matching your current state',
          icon: Icons.lightbulb_rounded,
          color: AppColors.cinematicGold,
          content: _buildMoodSuggestions(),
          controller: _insightControllers[1],
        ),
      ],
    );
  }

  Widget _buildSocialTrendsInsights() {
    return Column(
      children: [
        _buildInsightCard(
          title: 'Similar User Preferences',
          subtitle: 'What users with similar taste enjoy',
          icon: Icons.group_rounded,
          color: AppColors.cinematicBlue,
          content: _buildSimilarUserPreferences(),
          controller: _insightControllers[0],
        ),
        const SizedBox(height: 20),
        _buildInsightCard(
          title: 'Community Trends',
          subtitle: 'Popular content in your demographic',
          icon: Icons.trending_up_rounded,
          color: AppColors.cinematicPurple,
          content: _buildCommunityTrends(),
          controller: _insightControllers[1],
        ),
      ],
    );
  }

  Widget _buildDiscoveryEngineInsights() {
    return Column(
      children: [
        _buildInsightCard(
          title: 'AI Recommendation Score',
          subtitle: 'How our algorithm rates suggestions for you',
          icon: Icons.auto_awesome_rounded,
          color: AppColors.cinematicGold,
          content: _buildAIRecommendationScore(),
          controller: _insightControllers[0],
        ),
        const SizedBox(height: 20),
        _buildInsightCard(
          title: 'Discovery Factors',
          subtitle: 'Key elements influencing your recommendations',
          icon: Icons.psychology_rounded,
          color: AppColors.cinematicPurple,
          content: _buildDiscoveryFactors(),
          controller: _insightControllers[1],
        ),
      ],
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget content,
    required AnimationController controller,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: controller,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.darkTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                content,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGenrePreferences() {
    final genres = [
      {'name': 'Sci-Fi', 'percentage': 35, 'color': AppColors.cinematicBlue},
      {'name': 'Action', 'percentage': 28, 'color': AppColors.cinematicPurple},
      {'name': 'Drama', 'percentage': 22, 'color': AppColors.cinematicGold},
      {'name': 'Thriller', 'percentage': 15, 'color': Colors.orange},
    ];

    return Column(
      children: genres.map((genre) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  genre['name'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (genre['percentage'] as int) / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: genre['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${genre['percentage']}%',
                style: AppTypography.labelMedium.copyWith(
                  color: genre['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildViewingPatterns() {
    return Column(
      children: [
        _buildPatternItem(
          'Peak Viewing Time',
          '8:00 PM - 11:00 PM',
          Icons.schedule_rounded,
          AppColors.cinematicBlue,
        ),
        _buildPatternItem(
          'Average Session',
          '2.3 hours',
          Icons.timer_rounded,
          AppColors.cinematicPurple,
        ),
        _buildPatternItem(
          'Preferred Day',
          'Friday & Saturday',
          Icons.calendar_today_rounded,
          AppColors.cinematicGold,
        ),
        _buildPatternItem(
          'Binge Tendency',
          'High (3+ episodes)',
          Icons.play_circle_rounded,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildRatingTendencies() {
    return Column(
      children: [
        _buildPatternItem(
          'Average Rating',
          '7.8 / 10',
          Icons.star_rounded,
          AppColors.cinematicGold,
        ),
        _buildPatternItem(
          'Rating Distribution',
          'Mostly 7-9 range',
          Icons.bar_chart_rounded,
          AppColors.cinematicBlue,
        ),
        _buildPatternItem(
          'Critical vs Popular',
          'Prefers critically acclaimed',
          Icons.psychology_rounded,
          AppColors.cinematicPurple,
        ),
      ],
    );
  }

  Widget _buildMoodDetection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cinematicPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.psychology_rounded,
                color: AppColors.cinematicPurple,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Mood: Adventurous',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Based on recent sci-fi and action selections',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '87%',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.cinematicPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSuggestions() {
    final suggestions = [
      'High-energy action films',
      'Space exploration documentaries',
      'Mind-bending thrillers',
      'Epic fantasy series',
    ];

    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cinematicGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.cinematicGold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                color: AppColors.cinematicGold,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                suggestion,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimilarUserPreferences() {
    return Column(
      children: [
        _buildPatternItem(
          'User Similarity',
          '92% match with top users',
          Icons.people_rounded,
          AppColors.cinematicBlue,
        ),
        _buildPatternItem(
          'Shared Favorites',
          '23 movies in common',
          Icons.favorite_rounded,
          AppColors.cinematicPurple,
        ),
        _buildPatternItem(
          'Discovery Rate',
          '78% acceptance of suggestions',
          Icons.explore_rounded,
          AppColors.cinematicGold,
        ),
      ],
    );
  }

  Widget _buildCommunityTrends() {
    return Column(
      children: [
        _buildPatternItem(
          'Trending in Your Age Group',
          '25-34 years old',
          Icons.trending_up_rounded,
          AppColors.cinematicPurple,
        ),
        _buildPatternItem(
          'Regional Preferences',
          'Popular in your area',
          Icons.location_on_rounded,
          AppColors.cinematicBlue,
        ),
        _buildPatternItem(
          'Seasonal Trends',
          'Winter viewing patterns',
          Icons.ac_unit_rounded,
          AppColors.cinematicGold,
        ),
      ],
    );
  }

  Widget _buildAIRecommendationScore() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cinematicGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recommendation Accuracy',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '94.2%',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.cinematicGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.942,
            backgroundColor: AppColors.darkTextTertiary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cinematicGold),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your viewing history and feedback',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryFactors() {
    final factors = [
      {'name': 'Genre Preferences', 'weight': 35},
      {'name': 'Rating History', 'weight': 25},
      {'name': 'Viewing Time', 'weight': 20},
      {'name': 'Social Signals', 'weight': 20},
    ];

    return Column(
      children: factors.map((factor) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  factor['name'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.darkTextTertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (factor['weight'] as int) / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cinematicPurple,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${factor['weight']}%',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.cinematicPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForInsightType(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'group':
        return Icons.group_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.insights_rounded;
    }
  }

  void _selectInsightType(String insightType) {
    if (insightType != _selectedInsightType) {
      setState(() {
        _selectedInsightType = insightType;
      });
      HapticFeedback.selectionClick();

      // Restart animations for new insight type
      for (final controller in _insightControllers) {
        controller.reset();
        controller.forward();
      }
    }
  }

  void _showInsightDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'How Recommendations Work',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Our recommendation engine analyzes your viewing history, ratings, and preferences to suggest content you\'ll love. We use machine learning to understand your taste and match it with similar users and trending content.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.darkTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.cinematicGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
