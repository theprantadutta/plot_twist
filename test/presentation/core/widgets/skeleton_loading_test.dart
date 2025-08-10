import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/skeleton_loading.dart';

void main() {
  group('SkeletonLoading', () {
    testWidgets('should create shimmer effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.shimmer(
              child: Container(width: 100, height: 100, color: Colors.grey),
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('should create basic box skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SkeletonLoading.box(width: 100, height: 50)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 100);
      expect(container.constraints?.maxHeight, 50);
    });

    testWidgets('should create text skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SkeletonLoading.text(width: 150, height: 16)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 150);
      expect(container.constraints?.maxHeight, 16);
    });

    testWidgets('should create avatar skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SkeletonLoading.avatar(size: 60))),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 60);
      expect(container.constraints?.maxHeight, 60);

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('should create movie poster skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.moviePoster(width: 120, height: 180),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 120);
      expect(container.constraints?.maxHeight, 180);
      expect(find.byIcon(Icons.movie_rounded), findsOneWidget);
    });

    testWidgets('should create hero card skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.heroCard(width: 300, height: 200),
          ),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should create list item skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.listItem(
              showAvatar: true,
              showTrailing: true,
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should create grid item skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.gridItem(width: 160, height: 240),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('should create button skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SkeletonLoading.button(width: 120, height: 40)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 120);
      expect(container.constraints?.maxHeight, 40);
    });

    testWidgets('should create profile header skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.profileHeader(width: 400, height: 120),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should create stats card skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.statsCard(width: 150, height: 100),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.constraints?.maxWidth, 150);
      expect(container.constraints?.maxHeight, 100);
    });

    testWidgets('should create search bar skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.searchBar(width: 300, height: 48),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should create tab bar skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.tabBar(tabCount: 4, width: 300, height: 48),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Expanded), findsNWidgets(4));
    });

    testWidgets('should create rating stars skeleton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.ratingStars(starCount: 5, starSize: 16),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));
      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('SkeletonBuilder', () {
    testWidgets('should build skeleton when enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonBuilder(
              enabled: true,
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: 100,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(LayoutBuilder), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('should not build skeleton when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonBuilder(
              enabled: false,
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: 100,
                  color: Colors.grey,
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(LayoutBuilder), findsNothing);
    });
  });

  group('SkeletonList', () {
    testWidgets('should create skeleton list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonList(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(height: 60, color: Colors.grey);
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('should create horizontal skeleton list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonList(
              itemCount: 3,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(width: 100, color: Colors.grey);
              },
            ),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.scrollDirection, Axis.horizontal);
    });
  });

  group('SkeletonGrid', () {
    testWidgets('should create skeleton grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonGrid(
              itemCount: 6,
              crossAxisCount: 2,
              itemBuilder: (context, index) {
                return Container(color: Colors.grey);
              },
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('should use correct grid delegate', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonGrid(
              itemCount: 4,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              itemBuilder: (context, index) {
                return Container(color: Colors.grey);
              },
            ),
          ),
        ),
      );

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 2);
      expect(delegate.mainAxisSpacing, 16);
      expect(delegate.crossAxisSpacing, 16);
      expect(delegate.childAspectRatio, 1.5);
    });
  });

  group('_ShimmerWrapper', () {
    testWidgets('should animate shimmer effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.shimmer(
              duration: const Duration(milliseconds: 500),
              child: Container(width: 100, height: 100, color: Colors.grey),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);

      // Test animation
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
    });

    testWidgets('should use custom colors', (WidgetTester tester) async {
      const baseColor = Colors.red;
      const highlightColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoading.shimmer(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Container(width: 100, height: 100, color: Colors.grey),
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });
}
