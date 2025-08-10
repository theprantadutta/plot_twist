import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_colors.dart';
import '../../../core/app_typography.dart';
import '../../../core/app_animations.dart';

/// Enhanced cast and crew section with interactive features
class EnhancedCastAndCrewSection extends ConsumerStatefulWidget {
  final Map<String, dynamic> media;
  final String mediaType;

  const EnhancedCastAndCrewSection({
    super.key,
    required this.media,
    required this.mediaType,
  });

  @override
  ConsumerState<EnhancedCastAndCrewSection> createState() =>
      _EnhancedCastAndCrewSectionState();
}

class _EnhancedCastAndCrewSectionState
    extends ConsumerState<EnhancedCastAndCrewSection>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    _animationController.dispose();
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
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: 16),
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cast & Crew',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.darkTextPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextButton(
            onPressed: _showFullCastAndCrew,
            child: Text(
              'View All',
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.cinematicGold,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.black,
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTypography.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelLarge,
        tabs: const [
          Tab(text: 'Cast'),
          Tab(text: 'Crew'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 280,
      child: TabBarView(
        controller: _tabController,
        children: [_buildCastList(), _buildCrewList()],
      ),
    );
  }

  Widget _buildCastList() {
    // Mock cast data - in real app, this would come from API
    final mockCast = [
      {
        'id': 1,
        'name': 'Christian Bale',
        'character': 'Bruce Wayne / Batman',
        'profile_path': '/profile1.jpg',
        'popularity': 85.5,
      },
      {
        'id': 2,
        'name': 'Heath Ledger',
        'character': 'The Joker',
        'profile_path': '/profile2.jpg',
        'popularity': 92.3,
      },
      {
        'id': 3,
        'name': 'Aaron Eckhart',
        'character': 'Harvey Dent / Two-Face',
        'profile_path': '/profile3.jpg',
        'popularity': 78.1,
      },
      {
        'id': 4,
        'name': 'Michael Caine',
        'character': 'Alfred Pennyworth',
        'profile_path': '/profile4.jpg',
        'popularity': 88.7,
      },
      {
        'id': 5,
        'name': 'Gary Oldman',
        'character': 'James Gordon',
        'profile_path': '/profile5.jpg',
        'popularity': 82.4,
      },
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: mockCast.length,
      itemBuilder: (context, index) {
        final castMember = mockCast[index];
        return _buildCastCard(castMember, Duration(milliseconds: index * 100));
      },
    );
  }

  Widget _buildCrewList() {
    // Mock crew data - in real app, this would come from API
    final mockCrew = [
      {
        'id': 1,
        'name': 'Christopher Nolan',
        'job': 'Director',
        'department': 'Directing',
        'profile_path': '/crew1.jpg',
        'popularity': 95.2,
      },
      {
        'id': 2,
        'name': 'Jonathan Nolan',
        'job': 'Screenplay',
        'department': 'Writing',
        'profile_path': '/crew2.jpg',
        'popularity': 78.9,
      },
      {
        'id': 3,
        'name': 'Wally Pfister',
        'job': 'Director of Photography',
        'department': 'Camera',
        'profile_path': '/crew3.jpg',
        'popularity': 72.1,
      },
      {
        'id': 4,
        'name': 'Hans Zimmer',
        'job': 'Original Music Composer',
        'department': 'Sound',
        'profile_path': '/crew4.jpg',
        'popularity': 89.5,
      },
      {
        'id': 5,
        'name': 'Lee Smith',
        'job': 'Editor',
        'department': 'Editing',
        'profile_path': '/crew5.jpg',
        'popularity': 68.3,
      },
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: mockCrew.length,
      itemBuilder: (context, index) {
        final crewMember = mockCrew[index];
        return _buildCrewCard(crewMember, Duration(milliseconds: index * 100));
      },
    );
  }

  Widget _buildCastCard(Map<String, dynamic> castMember, Duration delay) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: TweenAnimationBuilder<double>(
        duration: MotionPresets.slideUp.duration + delay,
        tween: Tween(begin: 0.0, end: 1.0),
        curve: MotionPresets.slideUp.curve,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: GestureDetector(
          onTap: () => _showPersonDetails(castMember, 'cast'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.darkSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Placeholder for profile image
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.cinematicGold.withValues(alpha: 0.3),
                              AppColors.cinematicBlue.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.darkTextSecondary,
                          size: 48,
                        ),
                      ),

                      // Popularity indicator
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
                                '${castMember['popularity']?.toStringAsFixed(1) ?? '0.0'}',
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

              const SizedBox(height: 12),

              // Actor Name
              Text(
                castMember['name'] ?? 'Unknown Actor',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Character Name
              Text(
                castMember['character'] ?? 'Unknown Character',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCrewCard(Map<String, dynamic> crewMember, Duration delay) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      child: TweenAnimationBuilder<double>(
        duration: MotionPresets.slideUp.duration + delay,
        tween: Tween(begin: 0.0, end: 1.0),
        curve: MotionPresets.slideUp.curve,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(opacity: value, child: child),
          );
        },
        child: GestureDetector(
          onTap: () => _showPersonDetails(crewMember, 'crew'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.darkSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Placeholder for profile image
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.cinematicPurple.withValues(alpha: 0.3),
                              AppColors.cinematicRed.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.work_rounded,
                          color: AppColors.darkTextSecondary,
                          size: 48,
                        ),
                      ),

                      // Department badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getDepartmentColor(
                              crewMember['department'],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            crewMember['department'] ?? 'Other',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Crew Member Name
              Text(
                crewMember['name'] ?? 'Unknown Person',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Job Title
              Text(
                crewMember['job'] ?? 'Unknown Job',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDepartmentColor(String? department) {
    switch (department?.toLowerCase()) {
      case 'directing':
        return AppColors.cinematicGold;
      case 'writing':
        return AppColors.cinematicBlue;
      case 'camera':
        return AppColors.cinematicPurple;
      case 'sound':
        return AppColors.cinematicRed;
      case 'editing':
        return AppColors.darkSuccessGreen;
      default:
        return AppColors.darkTextSecondary;
    }
  }

  void _showPersonDetails(Map<String, dynamic> person, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildPersonDetailsSheet(person, type),
    );
  }

  Widget _buildPersonDetailsSheet(Map<String, dynamic> person, String type) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
            child: Row(
              children: [
                // Profile Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkSurface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.cinematicGold.withValues(alpha: 0.3),
                            AppColors.cinematicBlue.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                      child: Icon(
                        type == 'cast'
                            ? Icons.person_rounded
                            : Icons.work_rounded,
                        color: AppColors.darkTextSecondary,
                        size: 32,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Person Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person['name'] ?? 'Unknown Person',
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.darkTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type == 'cast'
                            ? (person['character'] ?? 'Unknown Character')
                            : (person['job'] ?? 'Unknown Job'),
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.cinematicGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (person['popularity'] != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.cinematicGold,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Popularity: ${person['popularity']?.toStringAsFixed(1)}',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Biography section (mock data)
                  Text(
                    'Biography',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This is a mock biography for ${person['name']}. In a real application, this would contain detailed information about the person\'s career, achievements, and background.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkTextSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Known For section
                  Text(
                    'Known For',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.darkTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.cinematicGold.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.movie_rounded,
                                      color: AppColors.cinematicGold,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Movie ${index + 1}',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.darkTextPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullCastAndCrew() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullCastAndCrewScreen(
          media: widget.media,
          mediaType: widget.mediaType,
        ),
      ),
    );
  }
}

/// Full cast and crew screen for detailed view
class FullCastAndCrewScreen extends StatefulWidget {
  final Map<String, dynamic> media;
  final String mediaType;

  const FullCastAndCrewScreen({
    super.key,
    required this.media,
    required this.mediaType,
  });

  @override
  State<FullCastAndCrewScreen> createState() => _FullCastAndCrewScreenState();
}

class _FullCastAndCrewScreenState extends State<FullCastAndCrewScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.darkTextPrimary,
          ),
        ),
        title: Text(
          'Cast & Crew',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.darkTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.darkTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search cast and crew...',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.darkTextSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.darkTextSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: Icon(
                              Icons.clear_rounded,
                              color: AppColors.darkTextSecondary,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.darkSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: AppColors.cinematicGold,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.cinematicGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: AppColors.darkTextSecondary,
                  labelStyle: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Cast'),
                    Tab(text: 'Crew'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFullCastList(), _buildFullCrewList()],
      ),
    );
  }

  Widget _buildFullCastList() {
    // Mock extended cast data
    final mockCast = List.generate(
      20,
      (index) => {
        'id': index + 1,
        'name': 'Actor ${index + 1}',
        'character': 'Character ${index + 1}',
        'profile_path': '/profile${index + 1}.jpg',
        'popularity': 50.0 + (index * 2.5),
      },
    );

    final filteredCast = mockCast.where((cast) {
      if (_searchQuery.isEmpty) return true;
      return (cast['name'] as String).toLowerCase().contains(_searchQuery) ||
          (cast['character'] as String).toLowerCase().contains(_searchQuery);
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredCast.length,
      itemBuilder: (context, index) {
        final castMember = filteredCast[index];
        return _buildFullCastCard(castMember);
      },
    );
  }

  Widget _buildFullCrewList() {
    // Mock extended crew data
    final mockCrew = List.generate(
      15,
      (index) => {
        'id': index + 1,
        'name': 'Crew Member ${index + 1}',
        'job': 'Job ${index + 1}',
        'department': [
          'Directing',
          'Writing',
          'Camera',
          'Sound',
          'Editing',
        ][index % 5],
        'profile_path': '/crew${index + 1}.jpg',
        'popularity': 40.0 + (index * 3.0),
      },
    );

    final filteredCrew = mockCrew.where((crew) {
      if (_searchQuery.isEmpty) return true;
      return (crew['name'] as String).toLowerCase().contains(_searchQuery) ||
          (crew['job'] as String).toLowerCase().contains(_searchQuery) ||
          (crew['department'] as String).toLowerCase().contains(_searchQuery);
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredCrew.length,
      itemBuilder: (context, index) {
        final crewMember = filteredCrew[index];
        return _buildFullCrewCard(crewMember);
      },
    );
  }

  Widget _buildFullCastCard(Map<String, dynamic> castMember) {
    return GestureDetector(
      onTap: () => _showPersonDetails(castMember, 'cast'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
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
                      AppColors.cinematicGold.withValues(alpha: 0.3),
                      AppColors.cinematicBlue.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.darkTextSecondary,
                    size: 48,
                  ),
                ),
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      castMember['name'] ?? 'Unknown Actor',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      castMember['character'] ?? 'Unknown Character',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.cinematicGold,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${castMember['popularity']?.toStringAsFixed(1) ?? '0.0'}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.darkTextSecondary,
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
      ),
    );
  }

  Widget _buildFullCrewCard(Map<String, dynamic> crewMember) {
    return GestureDetector(
      onTap: () => _showPersonDetails(crewMember, 'crew'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
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
                      AppColors.cinematicPurple.withValues(alpha: 0.3),
                      AppColors.cinematicRed.withValues(alpha: 0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.work_rounded,
                    color: AppColors.darkTextSecondary,
                    size: 48,
                  ),
                ),
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crewMember['name'] ?? 'Unknown Person',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      crewMember['job'] ?? 'Unknown Job',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDepartmentColor(crewMember['department']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        crewMember['department'] ?? 'Other',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDepartmentColor(String? department) {
    switch (department?.toLowerCase()) {
      case 'directing':
        return AppColors.cinematicGold;
      case 'writing':
        return AppColors.cinematicBlue;
      case 'camera':
        return AppColors.cinematicPurple;
      case 'sound':
        return AppColors.cinematicRed;
      case 'editing':
        return AppColors.darkSuccessGreen;
      default:
        return AppColors.darkTextSecondary;
    }
  }

  void _showPersonDetails(Map<String, dynamic> person, String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkSurface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.cinematicGold.withValues(alpha: 0.3),
                              AppColors.cinematicBlue.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                        child: Icon(
                          type == 'cast'
                              ? Icons.person_rounded
                              : Icons.work_rounded,
                          color: AppColors.darkTextSecondary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Person Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person['name'] ?? 'Unknown Person',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.darkTextPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type == 'cast'
                              ? (person['character'] ?? 'Unknown Character')
                              : (person['job'] ?? 'Unknown Job'),
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.cinematicGold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (person['popularity'] != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.cinematicGold,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Popularity: ${person['popularity']?.toStringAsFixed(1)}',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Biography section (mock data)
                    Text(
                      'Biography',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This is a mock biography for ${person['name']}. In a real application, this would contain detailed information about the person\'s career, achievements, and background.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.darkTextSecondary,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Known For section
                    Text(
                      'Known For',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.darkTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.cinematicGold.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.movie_rounded,
                                        color: AppColors.cinematicGold,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    'Movie ${index + 1}',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.darkTextPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
