import 'package:flutter/material.dart';
import 'cinematic_app_bar.dart';

/// Example usage of CinematicAppBar variations
class CinematicAppBarExample extends StatefulWidget {
  const CinematicAppBarExample({super.key});

  @override
  State<CinematicAppBarExample> createState() => _CinematicAppBarExampleState();
}

class _CinematicAppBarExampleState extends State<CinematicAppBarExample> {
  int _currentIndex = 0;
  bool _isFavorite = false;

  final List<_AppBarDemo> _demos = [
    _AppBarDemo(
      title: 'Transparent Overlay',
      description: 'Perfect for hero sections with background images',
      style: CinematicAppBarStyle.transparent,
      backgroundColor: Colors.blue,
    ),
    _AppBarDemo(
      title: 'Glassmorphism',
      description: 'Modern blur effect with transparency',
      style: CinematicAppBarStyle.glassmorphism,
      backgroundColor: Colors.purple,
    ),
    _AppBarDemo(
      title: 'Solid Background',
      description: 'Traditional solid app bar for content pages',
      style: CinematicAppBarStyle.solid,
      backgroundColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentDemo = _demos[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentDemo.backgroundColor,
              currentDemo.backgroundColor.withValues(alpha: 0.7),
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // App Bar
            _buildCurrentAppBar(currentDemo),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      currentDemo.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentDemo.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildStyleSelector(),
                    const Spacer(),
                    _buildFeatureList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCurrentAppBar(_AppBarDemo demo) {
    final actions = [
      CinematicAppBarActions.searchAction(
        onPressed: () => _showSnackBar('Search pressed'),
      ),
      CinematicAppBarActions.favoriteAction(
        isFavorite: _isFavorite,
        onPressed: () {
          setState(() {
            _isFavorite = !_isFavorite;
          });
          _showSnackBar(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          );
        },
      ),
      CinematicAppBarActions.moreAction(
        onPressed: () => _showSnackBar('More options pressed'),
      ),
    ];

    switch (demo.style) {
      case CinematicAppBarStyle.transparent:
        return TransparentOverlayAppBar(
          title: demo.title,
          actions: actions,
          onBackPressed: () => _showSnackBar('Back pressed'),
        );
      case CinematicAppBarStyle.glassmorphism:
        return GlassmorphismAppBar(
          title: demo.title,
          actions: actions,
          onBackPressed: () => _showSnackBar('Back pressed'),
        );
      case CinematicAppBarStyle.solid:
        return SolidAppBar(
          title: demo.title,
          actions: actions,
          elevation: 4,
          onBackPressed: () => _showSnackBar('Back pressed'),
        );
    }
  }

  Widget _buildStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App Bar Styles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: _demos.asMap().entries.map((entry) {
            final index = entry.key;
            final demo = entry.value;
            final isSelected = _currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    demo.title.split(' ').first,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Smooth slide-down animation',
      'Customizable actions and styling',
      'Automatic back button handling',
      'System UI overlay integration',
      'Responsive design support',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _AppBarDemo {
  final String title;
  final String description;
  final CinematicAppBarStyle style;
  final Color backgroundColor;

  const _AppBarDemo({
    required this.title,
    required this.description,
    required this.style,
    required this.backgroundColor,
  });
}

/// Advanced app bar transition example
class AppBarTransitionExample extends StatefulWidget {
  const AppBarTransitionExample({super.key});

  @override
  State<AppBarTransitionExample> createState() =>
      _AppBarTransitionExampleState();
}

class _AppBarTransitionExampleState extends State<AppBarTransitionExample> {
  final ScrollController _scrollController = ScrollController();
  CinematicAppBarStyle _currentStyle = CinematicAppBarStyle.transparent;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    CinematicAppBarStyle newStyle;

    if (offset < 100) {
      newStyle = CinematicAppBarStyle.transparent;
    } else if (offset < 200) {
      newStyle = CinematicAppBarStyle.glassmorphism;
    } else {
      newStyle = CinematicAppBarStyle.solid;
    }

    if (newStyle != _currentStyle) {
      setState(() {
        _currentStyle = newStyle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBarTransitionController(
      initialStyle: _currentStyle,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple, Colors.indigo, Colors.black],
            ),
          ),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Scroll Transition',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.deepPurple, Colors.transparent],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.movie_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Container(
                    height: 100,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Item ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }, childCount: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
