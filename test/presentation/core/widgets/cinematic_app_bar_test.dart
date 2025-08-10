import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/cinematic_app_bar.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';

void main() {
  group('CinematicAppBar', () {
    Widget createTestWidget({
      String? title,
      Widget? titleWidget,
      List<Widget>? actions,
      Widget? leading,
      CinematicAppBarStyle? style,
      VoidCallback? onBackPressed,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          appBar: CinematicAppBar(
            title: title,
            titleWidget: titleWidget,
            actions: actions,
            leading: leading,
            style: style ?? CinematicAppBarStyle.solid,
            onBackPressed: onBackPressed,
          ),
          body: const Center(child: Text('Test Content')),
        ),
      );
    }

    testWidgets('renders with title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'Test Title'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders with custom title widget', (
      WidgetTester tester,
    ) async {
      const customTitle = Text('Custom Title Widget');

      await tester.pumpWidget(createTestWidget(titleWidget: customTitle));
      await tester.pumpAndSettle();

      expect(find.text('Custom Title Widget'), findsOneWidget);
    });

    testWidgets('renders with actions', (WidgetTester tester) async {
      final actions = [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ];

      await tester.pumpWidget(
        createTestWidget(title: 'Test', actions: actions),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('renders with custom leading widget', (
      WidgetTester tester,
    ) async {
      final leading = IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {},
      );

      await tester.pumpWidget(
        createTestWidget(title: 'Test', leading: leading),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('calls onBackPressed when back button is tapped', (
      WidgetTester tester,
    ) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: CinematicAppBar(
                          title: 'Second Page',
                          onBackPressed: () => backPressed = true,
                        ),
                        body: const Center(child: Text('Second Page')),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Navigate to second page
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await tester.pumpAndSettle();

      expect(backPressed, isTrue);
    });

    group('Style Variations', () {
      testWidgets('renders transparent style correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            title: 'Transparent',
            style: CinematicAppBarStyle.transparent,
          ),
        );
        await tester.pumpAndSettle();

        // Verify AppBar is present
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Transparent'), findsOneWidget);
      });

      testWidgets('renders glassmorphism style correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            title: 'Glassmorphism',
            style: CinematicAppBarStyle.glassmorphism,
          ),
        );
        await tester.pumpAndSettle();

        // Verify BackdropFilter is present for blur effect
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(find.text('Glassmorphism'), findsOneWidget);
      });

      testWidgets('renders solid style correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(title: 'Solid', style: CinematicAppBarStyle.solid),
        );
        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Solid'), findsOneWidget);
      });
    });

    testWidgets('animates slide-down entrance', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(title: 'Animated'));

      // Initially, the app bar should be animating
      await tester.pump();

      // After animation completes
      await tester.pumpAndSettle();

      // App bar should be visible
      expect(find.byType(CinematicAppBar), findsOneWidget);
    });

    testWidgets('has correct preferred size', (WidgetTester tester) async {
      const customHeight = 80.0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: const CinematicAppBar(
              title: 'Test',
              toolbarHeight: customHeight,
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );

      final appBar = tester.widget<CinematicAppBar>(
        find.byType(CinematicAppBar),
      );
      expect(appBar.preferredSize.height, customHeight);
    });
  });

  group('TransparentOverlayAppBar', () {
    testWidgets('renders with transparent style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: const TransparentOverlayAppBar(
              title: 'Transparent Overlay',
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transparent Overlay'), findsOneWidget);
      expect(find.byType(CinematicAppBar), findsOneWidget);
    });

    testWidgets('calls onBackPressed correctly', (WidgetTester tester) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: TransparentOverlayAppBar(
                          title: 'Second Page',
                          onBackPressed: () => backPressed = true,
                        ),
                        body: const Center(child: Text('Second Page')),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await tester.pumpAndSettle();

      expect(backPressed, isTrue);
    });
  });

  group('GlassmorphismAppBar', () {
    testWidgets('renders with glassmorphism style', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: const GlassmorphismAppBar(title: 'Glassmorphism'),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Glassmorphism'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });
  });

  group('SolidAppBar', () {
    testWidgets('renders with solid style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: const SolidAppBar(title: 'Solid', elevation: 4),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solid'), findsOneWidget);
      expect(find.byType(CinematicAppBar), findsOneWidget);
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: const SolidAppBar(
              title: 'Custom Color',
              backgroundColor: Colors.red,
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final appBar = tester.widget<CinematicAppBar>(
        find.byType(CinematicAppBar),
      );
      expect(appBar.backgroundColor, Colors.red);
    });
  });

  group('AppBarTransitionController', () {
    testWidgets('creates controller correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: AppBarTransitionController(
            initialStyle: CinematicAppBarStyle.transparent,
            child: Scaffold(
              appBar: const CinematicAppBar(title: 'Test'),
              body: const Center(child: Text('Test Content')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBarTransitionController), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('can find controller from context', (
      WidgetTester tester,
    ) async {
      Object? controller;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: AppBarTransitionController(
            child: Scaffold(
              appBar: const CinematicAppBar(title: 'Test'),
              body: Builder(
                builder: (context) {
                  controller = AppBarTransitionController.of(context);
                  return const Center(child: Text('Test Content'));
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller, isNotNull);
    });
  });

  group('CinematicAppBarActions', () {
    testWidgets('creates search action correctly', (WidgetTester tester) async {
      bool searchPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: CinematicAppBar(
              title: 'Test',
              actions: [
                CinematicAppBarActions.searchAction(
                  onPressed: () => searchPressed = true,
                ),
              ],
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(searchPressed, isTrue);
    });

    testWidgets('creates favorite action correctly', (
      WidgetTester tester,
    ) async {
      bool favoritePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: CinematicAppBar(
              title: 'Test',
              actions: [
                CinematicAppBarActions.favoriteAction(
                  isFavorite: false,
                  onPressed: () => favoritePressed = true,
                ),
              ],
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_outline_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite_outline_rounded));
      await tester.pumpAndSettle();

      expect(favoritePressed, isTrue);
    });

    testWidgets('shows filled favorite icon when isFavorite is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: CinematicAppBar(
              title: 'Test',
              actions: [
                CinematicAppBarActions.favoriteAction(
                  isFavorite: true,
                  onPressed: () {},
                ),
              ],
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('creates share action correctly', (WidgetTester tester) async {
      bool sharePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: CinematicAppBar(
              title: 'Test',
              actions: [
                CinematicAppBarActions.shareAction(
                  onPressed: () => sharePressed = true,
                ),
              ],
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.share_rounded));
      await tester.pumpAndSettle();

      expect(sharePressed, isTrue);
    });

    testWidgets('creates more action correctly', (WidgetTester tester) async {
      bool morePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            appBar: CinematicAppBar(
              title: 'Test',
              actions: [
                CinematicAppBarActions.moreAction(
                  onPressed: () => morePressed = true,
                ),
              ],
            ),
            body: const Center(child: Text('Test Content')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();

      expect(morePressed, isTrue);
    });
  });
}
