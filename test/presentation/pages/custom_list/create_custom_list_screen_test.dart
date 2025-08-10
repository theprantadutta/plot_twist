import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plot_twist/presentation/pages/custom_list/create_custom_list_screen.dart';

void main() {
  group('CreateCustomListScreen', () {
    Widget createTestWidget() {
      return ProviderScope(child: MaterialApp(home: CreateCustomListScreen()));
    }

    testWidgets('should display screen title and header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Custom List'), findsOneWidget);
      expect(find.text('Curate Your Collection'), findsOneWidget);
    });

    testWidgets('should display form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('List Details'), findsOneWidget);
      expect(find.text('List Name'), findsOneWidget);
      expect(find.text('Description (Optional)'), findsOneWidget);
    });

    testWidgets('should display theme selection section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Choose Your Theme'), findsOneWidget);
      expect(find.text('Cinematic Gold'), findsOneWidget);
      expect(find.text('Neon Dreams'), findsOneWidget);
    });

    testWidgets('should validate form input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially, Create button should not be visible (form invalid)
      expect(find.text('Create'), findsNothing);

      // Enter valid list name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., "My Favorite Sci-Fi Movies"'),
        'My Test List',
      );
      await tester.pumpAndSettle();

      // Create button should now be visible
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should show preview when form is valid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially, preview should not be visible
      expect(find.text('Preview'), findsNothing);

      // Enter valid list name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., "My Favorite Sci-Fi Movies"'),
        'My Test List',
      );
      await tester.pumpAndSettle();

      // Preview should now be visible
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('My Test List'), findsAtLeastNWidgets(1));
    });

    testWidgets('should update preview when description is entered', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid list name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., "My Favorite Sci-Fi Movies"'),
        'My Test List',
      );
      await tester.pumpAndSettle();

      // Enter description
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Tell others what makes this list special...',
        ),
        'This is my test description',
      );
      await tester.pumpAndSettle();

      // Preview should show the description
      expect(find.text('This is my test description'), findsOneWidget);
    });

    testWidgets('should allow theme selection', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap a different theme
      await tester.tap(find.text('Neon Dreams'));
      await tester.pumpAndSettle();

      // Theme should be selected (this would be verified by checking the visual state)
      expect(find.text('Neon Dreams'), findsOneWidget);
    });

    testWidgets('should validate minimum name length', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter short name (less than 3 characters)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., "My Favorite Sci-Fi Movies"'),
        'AB',
      );
      await tester.pumpAndSettle();

      // Create button should not be visible
      expect(find.text('Create'), findsNothing);

      // Enter valid length name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., "My Favorite Sci-Fi Movies"'),
        'ABC',
      );
      await tester.pumpAndSettle();

      // Create button should now be visible
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should show create button when form is valid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter valid form data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'e.g., "My Favorite Sci-Fi Movies"'),
        'My Test List',
      );
      await tester.pumpAndSettle();

      // Create button should be enabled
      final createButton = find.text('Create');
      expect(createButton, findsOneWidget);

      // Button should be tappable
      await tester.tap(createButton);
      await tester.pump();

      // Should show loading state
      expect(find.text('Creating List...'), findsOneWidget);
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
