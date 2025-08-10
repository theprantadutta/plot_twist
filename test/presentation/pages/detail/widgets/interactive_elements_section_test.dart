import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/detail/widgets/interactive_elements_section.dart';

void main() {
  group('InteractiveElementsSection', () {
    late Map<String, dynamic> mockMedia;

    setUp(() {
      mockMedia = {
        'id': 1,
        'title': 'Test Movie',
        'overview': 'Test overview',
        'vote_average': 8.5,
        'release_date': '2023-01-01',
      };
    });

    Widget createTestWidget({
      required Map<String, dynamic> media,
      required String mediaType,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: InteractiveElementsSection(
              media: media,
              mediaType: mediaType,
            ),
          ),
        ),
      );
    }

    testWidgets('should display section header', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      expect(find.text('Take Action'), findsOneWidget);
    });

    testWidgets('should display action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      expect(find.text('Add to Watchlist'), findsOneWidget);
      expect(find.text('Add to Favorites'), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    });

    testWidgets('should display rating section for movie', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rate This Movie'), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(5));
    });

    testWidgets('should display rating section for TV show', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'tv'),
      );

      await tester.pumpAndSettle();

      expect(find.text('Rate This Show'), findsOneWidget);
    });

    testWidgets('should display similar content section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      expect(find.text('More Like This'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('should toggle watchlist state when button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      // Initially should show "Add to Watchlist"
      expect(find.text('Add to Watchlist'), findsOneWidget);

      // Tap the watchlist button
      await tester.tap(find.text('Add to Watchlist'));
      await tester.pumpAndSettle();

      // Should now show "In Watchlist"
      expect(find.text('In Watchlist'), findsOneWidget);
    });

    testWidgets('should toggle favorites state when button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      // Initially should show "Add to Favorites"
      expect(find.text('Add to Favorites'), findsOneWidget);

      // Tap the favorites button
      await tester.tap(find.text('Add to Favorites'));
      await tester.pumpAndSettle();

      // Should now show "Favorited"
      expect(find.text('Favorited'), findsOneWidget);
    });

    testWidgets('should update rating when star is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      // Find and tap the third star (rating of 3)
      final starButtons = find.byIcon(Icons.star_border_rounded);
      expect(starButtons, findsNWidgets(5));

      await tester.tap(starButtons.at(2)); // Third star (index 2)
      await tester.pumpAndSettle();

      // Should show filled stars and rating text
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.text('Average'), findsOneWidget);
    });

    testWidgets(
      'should show more actions bottom sheet when more button is tapped',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(media: mockMedia, mediaType: 'movie'),
        );

        await tester.pumpAndSettle();

        // Tap the more actions button
        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();

        // Should show the bottom sheet with actions
        expect(find.text('More Actions'), findsOneWidget);
        expect(find.text('Add to Custom List'), findsOneWidget);
        expect(find.text('Share'), findsOneWidget);
        expect(find.text('Download for Offline'), findsOneWidget);
        expect(find.text('Report Issue'), findsOneWidget);
      },
    );

    testWidgets('should display similar content cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      // Should display similar content cards
      expect(find.text('The Dark Knight Rises'), findsOneWidget);
      expect(find.text('Batman Begins'), findsOneWidget);
      expect(find.text('Joker'), findsOneWidget);
    });

    testWidgets('should show success snackbar when actions are performed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(media: mockMedia, mediaType: 'movie'),
      );

      await tester.pumpAndSettle();

      // Tap watchlist button
      await tester.tap(find.text('Add to Watchlist'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Added to Watchlist'), findsOneWidget);
    });
  });
}
