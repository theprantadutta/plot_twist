import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/glassmorphism_bottom_navigation.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('GlassmorphismBottomNavigation', () {
    late List<AppNavigationDestination> mockDestinations;

    setUp(() {
      mockDestinations = const [
        AppNavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        AppNavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Discover',
        ),
        AppNavigationDestination(
          icon: Icon(Icons.bookmark_outline_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: 'Library',
        ),
        AppNavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ];
    });

    Widget createTestWidget({
      int? selectedIndex,
      Function(int)? onItemTapped,
      List<AppNavigationDestination>? destinations,
      double? height,
      double? borderRadius,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: GlassmorphismBottomNavigation(
            selectedIndex: selectedIndex ?? 0,
            onItemTapped: onItemTapped ?? (index) {},
            destinations: destinations ?? mockDestinations,
            height: height ?? 80,
            borderRadius: borderRadius ?? 28,
          ),
        ),
      );
    }

    testWidgets('renders with navigation destinations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all destination labels are displayed
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify icons are displayed
      expect(find.byIcon(Icons.home_rounded), findsOneWidget); // Selected icon
      expect(
        find.byIcon(Icons.explore_outlined),
        findsOneWidget,
      ); // Unselected icon
    });

    testWidgets('highlights selected item correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(selectedIndex: 2));
      await tester.pumpAndSettle();

      // The selected item (Library) should show selected icon
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      // Other items should show unselected icons
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
    });

    testWidgets('calls onItemTapped when item is tapped', (
      WidgetTester tester,
    ) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onItemTapped: (index) => tappedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      // Tap the Discover item
      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });

    testWidgets(
      'does not call onItemTapped when already selected item is tapped',
      (WidgetTester tester) async {
        int tapCount = 0;

        await tester.pumpWidget(
          createTestWidget(
            selectedIndex: 0,
            onItemTapped: (index) => tapCount++,
          ),
        );
        await tester.pumpAndSettle();

        // Tap the already selected Home item
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();

        expect(tapCount, 0);
      },
    );

    testWidgets('applies custom height', (WidgetTester tester) async {
      const customHeight = 100.0;

      await tester.pumpWidget(createTestWidget(height: customHeight));
      await tester.pumpAndSettle();

      // Verify the widget was created with custom height
      final navigationWidget = tester.widget<GlassmorphismBottomNavigation>(
        find.byType(GlassmorphismBottomNavigation),
      );
      expect(navigationWidget.height, customHeight);
    });

    testWidgets('applies custom border radius', (WidgetTester tester) async {
      const customRadius = 40.0;

      await tester.pumpWidget(createTestWidget(borderRadius: customRadius));
      await tester.pumpAndSettle();

      // Verify the widget was created with custom border radius
      final navigationWidget = tester.widget<GlassmorphismBottomNavigation>(
        find.byType(GlassmorphismBottomNavigation),
      );
      expect(navigationWidget.borderRadius, customRadius);
    });

    testWidgets('applies custom margin', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(24);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GlassmorphismBottomNavigation(
              selectedIndex: 0,
              onItemTapped: (index) {},
              destinations: mockDestinations,
              margin: customMargin,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the widget was created with custom margin
      final navigationWidget = tester.widget<GlassmorphismBottomNavigation>(
        find.byType(GlassmorphismBottomNavigation),
      );
      expect(navigationWidget.margin, customMargin);
    });

    testWidgets('displays BackdropFilter for glassmorphism effect', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify BackdropFilter is present for blur effect
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('handles different number of destinations', (
      WidgetTester tester,
    ) async {
      final twoDestinations = mockDestinations.take(2).toList();

      await tester.pumpWidget(createTestWidget(destinations: twoDestinations));
      await tester.pumpAndSettle();

      // Verify only two destinations are displayed
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Library'), findsNothing);
      expect(find.text('Profile'), findsNothing);
    });

    testWidgets('animates slide-up entrance', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially, the navigation should be animating
      await tester.pump();

      // After animation completes
      await tester.pumpAndSettle();

      // Navigation should be visible
      expect(find.byType(GlassmorphismBottomNavigation), findsOneWidget);
    });

    testWidgets('shows selection indicator for selected item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(selectedIndex: 1));
      await tester.pumpAndSettle();

      // The selection indicator should be present (AnimatedContainer)
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('handles tap on different items correctly', (
      WidgetTester tester,
    ) async {
      final tappedIndices = <int>[];

      await tester.pumpWidget(
        createTestWidget(
          selectedIndex: 0,
          onItemTapped: (index) => tappedIndices.add(index),
        ),
      );
      await tester.pumpAndSettle();

      // Tap different items
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(tappedIndices, [2, 3]);
    });
  });

  group('AppNavigationDestination', () {
    testWidgets('creates destination with required properties', (
      WidgetTester tester,
    ) async {
      const destination = AppNavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      );

      expect(destination.icon, isA<Icon>());
      expect(destination.selectedIcon, isA<Icon>());
      expect(destination.label, 'Home');
    });

    testWidgets('creates destination without selected icon', (
      WidgetTester tester,
    ) async {
      const destination = AppNavigationDestination(
        icon: Icon(Icons.home_outlined),
        label: 'Home',
      );

      expect(destination.icon, isA<Icon>());
      expect(destination.selectedIcon, isNull);
      expect(destination.label, 'Home');
    });
  });

  group('AppNavigationDestinations', () {
    testWidgets('provides main navigation destinations', (
      WidgetTester tester,
    ) async {
      final destinations = AppNavigationDestinations.main;

      expect(destinations.length, 4);
      expect(destinations[0].label, 'Home');
      expect(destinations[1].label, 'Discover');
      expect(destinations[2].label, 'Library');
      expect(destinations[3].label, 'Profile');
    });

    testWidgets('provides extended navigation destinations', (
      WidgetTester tester,
    ) async {
      final destinations = AppNavigationDestinations.extended;

      expect(destinations.length, 5);
      expect(destinations[0].label, 'Home');
      expect(destinations[1].label, 'Discover');
      expect(destinations[2].label, 'Library');
      expect(destinations[3].label, 'Favorites');
      expect(destinations[4].label, 'Profile');
    });
  });

  group('CinematicBottomNavigation', () {
    testWidgets('renders with predefined styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CinematicBottomNavigation(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify it uses the main destinations
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('calls onItemTapped correctly', (WidgetTester tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CinematicBottomNavigation(
              selectedIndex: 0,
              onItemTapped: (index) => tappedIndex = index,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();

      expect(tappedIndex, 1);
    });
  });

  group('CompactBottomNavigation', () {
    testWidgets('renders with compact styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CompactBottomNavigation(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify it renders the navigation
      expect(find.byType(GlassmorphismBottomNavigation), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('FloatingNavigationWrapper', () {
    testWidgets('wraps content with floating navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: FloatingNavigationWrapper(
            navigation: CinematicBottomNavigation(
              selectedIndex: 0,
              onItemTapped: (index) {},
            ),
            child: const Center(child: Text('Main Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify both content and navigation are present
      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);

      // Verify Scaffold with extendBody is used
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBody, isTrue);
    });
  });
}
