import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/responsive/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    testWidgets('should show mobile layout on small screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveLayout(
              mobile: const Text('Mobile'),
              tablet: const Text('Tablet'),
              desktop: const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should show tablet layout on medium screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: ResponsiveLayout(
              mobile: const Text('Mobile'),
              tablet: const Text('Tablet'),
              desktop: const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should show desktop layout on large screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: ResponsiveLayout(
              mobile: const Text('Mobile'),
              tablet: const Text('Tablet'),
              desktop: const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsNothing);
      expect(find.text('Tablet'), findsNothing);
      expect(find.text('Desktop'), findsOneWidget);
    });

    testWidgets('should fallback to mobile when tablet not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: ResponsiveLayout(
              mobile: const Text('Mobile'),
              desktop: const Text('Desktop'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Desktop'), findsNothing);
    });

    testWidgets('should use custom breakpoints', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(700, 600)),
            child: ResponsiveLayout(
              mobile: const Text('Mobile'),
              tablet: const Text('Tablet'),
              mobileBreakpoint: 800,
            ),
          ),
        ),
      );

      expect(find.text('Mobile'), findsOneWidget);
      expect(find.text('Tablet'), findsNothing);
    });
  });

  group('ResponsiveBreakpoints', () {
    testWidgets('should correctly identify mobile screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveBreakpoints.isMobile(context), isTrue);
                expect(ResponsiveBreakpoints.isTablet(context), isFalse);
                expect(ResponsiveBreakpoints.isDesktop(context), isFalse);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should correctly identify tablet screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveBreakpoints.isMobile(context), isFalse);
                expect(ResponsiveBreakpoints.isTablet(context), isTrue);
                expect(ResponsiveBreakpoints.isDesktop(context), isFalse);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should correctly identify desktop screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveBreakpoints.isMobile(context), isFalse);
                expect(ResponsiveBreakpoints.isTablet(context), isFalse);
                expect(ResponsiveBreakpoints.isDesktop(context), isTrue);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should get correct device type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(
                  ResponsiveBreakpoints.getDeviceType(context),
                  DeviceType.mobile,
                );
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should get responsive values correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                final value = ResponsiveBreakpoints.getResponsiveValue(
                  context,
                  mobile: 16.0,
                  tablet: 24.0,
                  desktop: 32.0,
                );
                expect(value, 24.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should fallback to mobile value when others not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                final value = ResponsiveBreakpoints.getResponsiveValue(
                  context,
                  mobile: 16.0,
                );
                expect(value, 16.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('ResponsivePadding', () {
    testWidgets('should provide correct horizontal padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final padding = ResponsivePadding.horizontal(context);
                expect(padding, const EdgeInsets.symmetric(horizontal: 16.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide correct vertical padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                final padding = ResponsivePadding.vertical(context);
                expect(padding, const EdgeInsets.symmetric(vertical: 20.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide correct all-around padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final padding = ResponsivePadding.all(context);
                expect(padding, const EdgeInsets.all(32.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide custom responsive padding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final padding = ResponsivePadding.custom(
                  context,
                  mobile: 20.0,
                  tablet: 30.0,
                );
                expect(padding, const EdgeInsets.all(20.0));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('ResponsiveSpacing', () {
    testWidgets('should provide correct spacing values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                expect(ResponsiveSpacing.small(context), 8.0);
                expect(ResponsiveSpacing.medium(context), 16.0);
                expect(ResponsiveSpacing.large(context), 24.0);
                expect(ResponsiveSpacing.extraLarge(context), 32.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide custom spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                final spacing = ResponsiveSpacing.get(
                  context,
                  mobile: 10.0,
                  tablet: 15.0,
                );
                expect(spacing, 15.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('ResponsiveGrid', () {
    testWidgets('should provide correct column count', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final columns = ResponsiveGrid.getColumnCount(
                  context,
                  mobile: 2,
                  tablet: 3,
                  desktop: 4,
                );
                expect(columns, 2);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide correct aspect ratio', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final aspectRatio = ResponsiveGrid.getAspectRatio(
                  context,
                  mobile: 0.8,
                  tablet: 0.9,
                  desktop: 1.0,
                );
                expect(aspectRatio, 1.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide correct spacing values', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: Builder(
              builder: (context) {
                final crossSpacing = ResponsiveGrid.getCrossAxisSpacing(
                  context,
                );
                final mainSpacing = ResponsiveGrid.getMainAxisSpacing(context);
                expect(crossSpacing, 16.0);
                expect(mainSpacing, 16.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('ResponsiveTypography', () {
    testWidgets('should provide correct font size', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final fontSize = ResponsiveTypography.getFontSize(
                  context,
                  mobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
                );
                expect(fontSize, 14.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('should provide correct line height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final lineHeight = ResponsiveTypography.getLineHeight(
                  context,
                  mobile: 1.2,
                  tablet: 1.3,
                  desktop: 1.4,
                );
                expect(lineHeight, 1.4);
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('should create responsive container', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveContainer(child: const Text('Content')),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should center content on non-mobile screens', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: ResponsiveContainer(child: const Text('Content')),
          ),
        ),
      );

      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('should not center content when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: ResponsiveContainer(
              centerContent: false,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsNothing);
    });
  });

  group('ResponsiveFlex', () {
    testWidgets('should use vertical direction on mobile', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveFlex(
              children: const [Text('Item 1'), Text('Item 2')],
            ),
          ),
        ),
      );

      final flex = tester.widget<Flex>(find.byType(Flex));
      expect(flex.direction, Axis.vertical);
    });

    testWidgets('should use horizontal direction on desktop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 800)),
            child: ResponsiveFlex(
              children: const [Text('Item 1'), Text('Item 2')],
            ),
          ),
        ),
      );

      final flex = tester.widget<Flex>(find.byType(Flex));
      expect(flex.direction, Axis.horizontal);
    });

    testWidgets('should respect forced direction', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveFlex(
              forceDirection: Axis.horizontal,
              children: const [Text('Item 1'), Text('Item 2')],
            ),
          ),
        ),
      );

      final flex = tester.widget<Flex>(find.byType(Flex));
      expect(flex.direction, Axis.horizontal);
    });

    testWidgets('should add spacing between children', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveFlex(
              spacing: 16.0,
              children: const [Text('Item 1'), Text('Item 2')],
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('ResponsiveWrap', () {
    testWidgets('should create wrap with responsive spacing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveWrap(
              children: const [Text('Item 1'), Text('Item 2'), Text('Item 3')],
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('should use custom spacing when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveWrap(
              spacing: 20.0,
              runSpacing: 25.0,
              children: const [Text('Item 1'), Text('Item 2')],
            ),
          ),
        ),
      );

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 20.0);
      expect(wrap.runSpacing, 25.0);
    });
  });
}
