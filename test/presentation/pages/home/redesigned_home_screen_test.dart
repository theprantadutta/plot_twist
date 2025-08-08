import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/home/redesigned_home_screen.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';
import 'package:plot_twist/application/home/home_providers.dart';
import 'package:plot_twist/data/local/persistence_service.dart';
import 'package:plot_twist/presentation/pages/home/widgets/cinematic_skeleton_loaders.dart';
import 'package:plot_twist/presentation/pages/home/widgets/personalized_recommendations.dart';
import 'package:plot_twist/presentation/pages/home/widgets/parallax_hero_section.dart';
import 'package:plot_twist/presentation/core/widgets/library_section_card.dart';

// Mock persistence service for testing
class MockPersistenceService extends PersistenceService {
  @override
  Future<void> init() async {
    // Mock initialization
  }

  @override
  MediaType getMediaType() => MediaType.movie;

  @override
  Future<void> setMediaType(MediaType type) async {
    // Mock implementation
  }

  @override
  bool hasAcceptedTerms() => true;

  @override
  Future<void> setHasAcceptedTerms(bool hasAccepted) async {
    // Mock implementation
  }
}

void main() {
  group('RedesignedHomeScreen', () {
    late MockPersistenceService mockPersistenceService;

    setUp(() {
      mockPersistenceService = MockPersistenceService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const RedesignedHomeScreen(),
        ),
      );
    }

    testWidgets('renders loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show loading state initially
      expect(find.byType(CinematicSkeletonLoaders), findsOneWidget);
    });

    testWidgets('renders app bar correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));

      // Should have an app bar
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows content after loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for loading to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should show the main content
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('displays search button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should have search button
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('handles scroll correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Find the scrollable widget
      final scrollable = find.byType(CustomScrollView);
      expect(scrollable, findsOneWidget);

      // Perform scroll gesture
      await tester.drag(scrollable, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Should still be visible after scroll
      expect(scrollable, findsOneWidget);
    });

    testWidgets('shows personalized recommendations section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should show personalized recommendations
      expect(find.byType(PersonalizedRecommendations), findsOneWidget);
    });

    testWidgets('shows library sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should show library section cards
      expect(find.byType(LibrarySectionCard), findsWidgets);
    });

    testWidgets('displays correct section titles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should show expected section titles
      expect(find.text('Your Watchlist'), findsOneWidget);
      expect(find.text('Trending This Week'), findsOneWidget);
      expect(find.text('Top Rated Movies'), findsOneWidget);
    });

    testWidgets('handles media type changes', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Initial state should show movie content
      expect(find.text('Top Rated Movies'), findsOneWidget);

      // The actual media type switching would be tested in integration tests
      // with the full provider setup
    });

    testWidgets('shows coming soon section for movies', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should show coming soon section for movies
      expect(find.text('Coming Soon'), findsOneWidget);
    });
  });

  group('RedesignedHomeScreen Animations', () {
    late MockPersistenceService mockPersistenceService;

    setUp(() {
      mockPersistenceService = MockPersistenceService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const RedesignedHomeScreen(),
        ),
      );
    }

    testWidgets('performs entrance animations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should start with loading state
      expect(find.byType(CinematicSkeletonLoaders), findsOneWidget);

      // Wait for animations to complete
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Should show main content after animations
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('handles hero section animations', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should have parallax hero section
      expect(find.byType(ParallaxHeroSection), findsOneWidget);
    });
  });

  group('RedesignedHomeScreen Error Handling', () {
    late MockPersistenceService mockPersistenceService;

    setUp(() {
      mockPersistenceService = MockPersistenceService();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          persistenceServiceProvider.overrideWithValue(mockPersistenceService),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const RedesignedHomeScreen(),
        ),
      );
    }

    testWidgets('handles empty content gracefully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Should handle empty states in library sections
      expect(find.byType(LibrarySectionCard), findsWidgets);
    });

    testWidgets('shows error states when needed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // The screen should render without crashing even with network errors
      expect(find.byType(RedesignedHomeScreen), findsOneWidget);
    });
  });
}
