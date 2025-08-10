import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/custom_list/custom_list_display_screen.dart';

void main() {
  group('CustomListDisplayScreen', () {
    late Map<String, dynamic> mockCustomList;

    setUp(() {
      mockCustomList = {
        'id': 1,
        'name': 'My Favorite Movies',
        'description': 'A collection of my all-time favorite films',
        'theme': 'cinematic',
        'created_at': '2024-01-01',
      };
    });

    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: CustomListDisplayScreen(customList: mockCustomList),
        ),
      );
    }

    testWidgets('should display list name and description in hero section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Favorite Movies'), findsOneWidget);
      expect(
        find.text('A collection of my all-time favorite films'),
        findsOneWidget,
      );
    });

    testWidgets('should display list stats', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('items'), findsOneWidget);
      expect(find.text('Cinematic Gold'), findsOneWidget);
    });

    testWidgets('should display view toggle buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.view_list_rounded), findsOneWidget);
    });

    testWidgets('should display edit and sort buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
    });

    testWidgets('should display floating action button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Add Content'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should toggle between grid and list view', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially should be in grid view
      // Tap list view button
      await tester.tap(find.byIcon(Icons.view_list_rounded));
      await tester.pumpAndSettle();

      // Should switch to list view
      // Tap grid view button
      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pumpAndSettle();

      // Should switch back to grid view
    });

    testWidgets('should toggle edit mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially should show "Edit"
      expect(find.text('Edit'), findsOneWidget);

      // Tap edit button
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Should now show "Done"
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('should show sort options when sort button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap sort button
      await tester.tap(find.byIcon(Icons.sort_rounded));
      await tester.pumpAndSettle();

      // Should show sort options
      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Date Added'), findsOneWidget);
      expect(find.text('Title (A-Z)'), findsOneWidget);
      expect(find.text('Rating'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
    });

    testWidgets('should show more options when more button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap more options button
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      // Should show more options
      expect(find.text('List Options'), findsOneWidget);
      expect(find.text('Edit List Details'), findsOneWidget);
      expect(find.text('Change Theme'), findsOneWidget);
      expect(find.text('Export List'), findsOneWidget);
      expect(find.text('Collaborate'), findsOneWidget);
      expect(find.text('Delete List'), findsOneWidget);
    });

    testWidgets('should display list items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should display mock list items
      expect(find.text('The Dark Knight'), findsOneWidget);
      expect(find.text('Inception'), findsOneWidget);
      expect(find.text('Breaking Bad'), findsOneWidget);
    });

    testWidgets('should show add content snackbar when FAB is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap floating action button
      await tester.tap(find.text('Add Content'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(
        find.text('Add content functionality coming soon!'),
        findsOneWidget,
      );
    });

    testWidgets('should handle empty list name gracefully', (
      WidgetTester tester,
    ) async {
      final emptyList = <String, dynamic>{'id': 1, 'theme': 'cinematic'};

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CustomListDisplayScreen(customList: emptyList),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Untitled List'), findsOneWidget);
    });
  });
}
