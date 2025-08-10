import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/custom_list/widgets/list_sharing_widget.dart';
import 'package:plot_twist/presentation/pages/custom_list/create_custom_list_screen.dart';

void main() {
  group('ListSharingWidget', () {
    late Map<String, dynamic> mockCustomList;
    late List<Map<String, dynamic>> mockListItems;
    late CustomListTheme mockTheme;

    setUp(() {
      mockCustomList = {
        'id': 1,
        'name': 'My Favorite Movies',
        'description': 'A collection of my all-time favorite films',
        'theme': 'cinematic',
        'created_at': '2024-01-01',
      };

      mockListItems = [
        {
          'id': 1,
          'title': 'The Dark Knight',
          'year': 2008,
          'type': 'movie',
          'rating': 9.0,
        },
        {
          'id': 2,
          'title': 'Inception',
          'year': 2010,
          'type': 'movie',
          'rating': 8.8,
        },
      ];

      mockTheme = const CustomListTheme(
        id: 'cinematic',
        name: 'Cinematic Gold',
        primaryColor: Colors.amber,
        secondaryColor: Colors.red,
        gradient: LinearGradient(colors: [Colors.amber, Colors.red]),
        description: 'Classic movie theater vibes',
      );
    });

    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ListSharingWidget(
              customList: mockCustomList,
              listItems: mockListItems,
              theme: mockTheme,
            ),
          ),
        ),
      );
    }

    testWidgets('should display sharing header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Share Your List'), findsOneWidget);
      expect(
        find.text('Create beautiful previews and share with friends'),
        findsOneWidget,
      );
    });

    testWidgets('should display preview section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Regenerate Preview'), findsOneWidget);
    });

    testWidgets('should display share format options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Share Format'), findsOneWidget);
      expect(find.text('Social Media'), findsOneWidget);
      expect(find.text('Story Format'), findsOneWidget);
      expect(find.text('Share Link'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
    });

    testWidgets('should display customization options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Customize Preview'), findsOneWidget);
      expect(find.text('Include Description'), findsOneWidget);
      expect(find.text('Include Stats'), findsOneWidget);
      expect(find.text('Include Posters'), findsOneWidget);
    });

    testWidgets('should display action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Share to Social Media'), findsOneWidget);
      expect(find.text('Copy Link'), findsOneWidget);
      expect(find.text('Save Image'), findsOneWidget);
    });

    testWidgets('should allow format selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Story Format
      await tester.tap(find.text('Story Format'));
      await tester.pumpAndSettle();

      // Should update the action button text
      expect(find.text('Share to Story'), findsOneWidget);
    });

    testWidgets('should toggle customization options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find switches and toggle them
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      // Toggle first switch (Include Description)
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Switch should be toggled
      final firstSwitch = tester.widget<Switch>(switches.first);
      expect(firstSwitch.value, isFalse);
    });

    testWidgets('should show regenerate preview loading state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap regenerate preview button
      await tester.tap(find.text('Regenerate Preview'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Generating preview...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle share action', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap share button
      await tester.tap(find.text('Share to Social Media'));
      await tester.pumpAndSettle();

      // Should show snackbar
      expect(find.textContaining('Sharing'), findsOneWidget);
    });

    testWidgets('should handle copy link action', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap copy link button
      await tester.tap(find.text('Copy Link'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Link copied to clipboard!'), findsOneWidget);
    });

    testWidgets('should handle save image action', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap save image button
      await tester.tap(find.text('Save Image'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Image saved to gallery!'), findsOneWidget);
    });
  });

  group('CustomListTheme', () {
    test('should create theme with all required properties', () {
      const theme = CustomListTheme(
        id: 'test',
        name: 'Test Theme',
        primaryColor: Colors.blue,
        secondaryColor: Colors.red,
        gradient: LinearGradient(colors: [Colors.blue, Colors.red]),
        description: 'Test description',
      );

      expect(theme.id, 'test');
      expect(theme.name, 'Test Theme');
      expect(theme.primaryColor, Colors.blue);
      expect(theme.secondaryColor, Colors.red);
      expect(theme.description, 'Test description');
    });
  });
}
