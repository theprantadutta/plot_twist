import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/loading_state_manager.dart';

void main() {
  group('LoadingStateManager', () {
    testWidgets('should show loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateManager(
              state: LoadingState.loading,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsNothing);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should show loaded content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateManager(
              state: LoadingState.loaded,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should show error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateManager(
              state: LoadingState.error,
              errorMessage: 'Test error',
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsNothing);
      expect(find.text('Oops!'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('should show empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateManager(
              state: LoadingState.empty,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsNothing);
      expect(find.text('No content available'), findsOneWidget);
    });

    testWidgets('should use custom skeleton', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateManager(
              state: LoadingState.loading,
              skeleton: const Text('Custom Skeleton'),
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Skeleton'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('should use custom error widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateManager(
              state: LoadingState.error,
              error: const Text('Custom Error'),
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.text('Content'), findsNothing);
    });

    testWidgets('should animate state transitions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateManager(
              state: LoadingState.loading,
              transitionDuration: const Duration(milliseconds: 100),
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });
  });

  group('ErrorStateWidget', () {
    testWidgets('should display error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ErrorStateWidget(message: 'Test error message')),
        ),
      );

      expect(find.text('Oops!'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('should show retry button when callback provided', (
      WidgetTester tester,
    ) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              message: 'Test error',
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retryPressed, isTrue);
    });

    testWidgets('should use custom retry text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              message: 'Test error',
              retryText: 'Custom Retry',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Custom Retry'), findsOneWidget);
    });

    testWidgets('should use custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(
              message: 'Test error',
              icon: Icons.warning_rounded,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });
  });

  group('EmptyStateWidget', () {
    testWidgets('should display empty message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: EmptyStateWidget(message: 'No items found')),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });

    testWidgets('should show subtitle when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'No items found',
              subtitle: 'Try adding some items',
            ),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Try adding some items'), findsOneWidget);
    });

    testWidgets('should show action when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'No items found',
              action: ElevatedButton(
                onPressed: () {},
                child: const Text('Add Item'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Add Item'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should use custom icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              message: 'No items found',
              icon: Icons.search_rounded,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });
  });

  group('ScreenLoadingManager', () {
    testWidgets('should create home screen loading manager', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenLoadingManager.home(
              state: LoadingState.loading,
              child: const Text('Home Content'),
            ),
          ),
        ),
      );

      expect(find.byType(LoadingStateManager), findsOneWidget);
      expect(find.text('Home Content'), findsNothing);
    });

    testWidgets('should create discover screen loading manager', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenLoadingManager.discover(
              state: LoadingState.loaded,
              child: const Text('Discover Content'),
            ),
          ),
        ),
      );

      expect(find.text('Discover Content'), findsOneWidget);
    });

    testWidgets('should handle retry callback', (WidgetTester tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScreenLoadingManager.profile(
              state: LoadingState.error,
              child: const Text('Profile Content'),
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      expect(retryPressed, isTrue);
    });
  });

  group('ComponentLoadingManager', () {
    testWidgets('should create movie poster loading manager', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentLoadingManager.moviePoster(
              state: LoadingState.loading,
              child: const Text('Movie Poster'),
              width: 120,
              height: 180,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingStateManager), findsOneWidget);
      expect(find.text('Movie Poster'), findsNothing);
    });

    testWidgets('should create list item loading manager', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComponentLoadingManager.listItem(
              state: LoadingState.loaded,
              child: const Text('List Item'),
              showAvatar: true,
              showTrailing: false,
            ),
          ),
        ),
      );

      expect(find.text('List Item'), findsOneWidget);
    });
  });

  group('LoadingStateBuilder', () {
    testWidgets('should build loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateBuilder(
              state: LoadingState.loading,
              loadingBuilder: () => const Text('Loading...'),
              loadedBuilder: () => const Text('Loaded'),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.text('Loaded'), findsNothing);
    });

    testWidgets('should build loaded state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateBuilder(
              state: LoadingState.loaded,
              loadingBuilder: () => const Text('Loading...'),
              loadedBuilder: () => const Text('Loaded'),
            ),
          ),
        ),
      );

      expect(find.text('Loaded'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('should build custom error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateBuilder(
              state: LoadingState.error,
              loadingBuilder: () => const Text('Loading...'),
              loadedBuilder: () => const Text('Loaded'),
              errorBuilder: () => const Text('Custom Error'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.text('Loaded'), findsNothing);
    });

    testWidgets('should build default error state when no custom builder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingStateBuilder(
              state: LoadingState.error,
              loadingBuilder: () => const Text('Loading...'),
              loadedBuilder: () => const Text('Loaded'),
            ),
          ),
        ),
      );

      expect(find.byType(ErrorStateWidget), findsOneWidget);
    });
  });

  group('SkeletonToContentTransition', () {
    testWidgets('should show skeleton when loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonToContentTransition(
              skeleton: Text('Skeleton'),
              content: Text('Content'),
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.text('Skeleton'), findsOneWidget);
      expect(
        find.text('Content'),
        findsOneWidget,
      ); // Content is there but faded
    });

    testWidgets('should transition to content when not loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonToContentTransition(
              skeleton: Text('Skeleton'),
              content: Text('Content'),
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Skeleton'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('should animate transition', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonToContentTransition(
              skeleton: Text('Skeleton'),
              content: Text('Content'),
              isLoading: true,
              duration: Duration(milliseconds: 100),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedOpacity), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
    });
  });
}
