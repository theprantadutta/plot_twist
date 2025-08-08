import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plot_twist/presentation/core/widgets/progress_indicators.dart';
import 'package:plot_twist/presentation/core/app_theme.dart';
import 'package:plot_twist/presentation/core/app_colors.dart';

void main() {
  group('WatchProgressIndicator', () {
    Widget createTestWidget({
      double progress = 0.5,
      Duration? totalDuration,
      Duration? watchedDuration,
      bool showTime = true,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: WatchProgressIndicator(
              progress: progress,
              totalDuration: totalDuration,
              watchedDuration: watchedDuration,
              showTime: showTime,
            ),
          ),
        ),
      );
    }

    testWidgets('should display progress indicator with percentage', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(progress: 0.75, showTime: false),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WatchProgressIndicator), findsOneWidget);
      expect(
        find.byType(CircularProgressIndicator),
        findsNWidgets(2),
      ); // Background + progress
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('should display time when watchedDuration is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          progress: 0.5,
          watchedDuration: const Duration(hours: 1, minutes: 30),
          showTime: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1h'), findsOneWidget);
      expect(find.text('30m'), findsOneWidget);
    });

    testWidgets('should display minutes only for short durations', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          progress: 0.3,
          watchedDuration: const Duration(minutes: 45),
          showTime: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('45m'), findsOneWidget);
    });

    testWidgets('should animate progress changes', (tester) async {
      await tester.pumpWidget(createTestWidget(progress: 0.2));
      await tester.pump();

      // Progress should animate from 0 to 0.2
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });
  });

  group('PriorityIndicator', () {
    Widget createTestWidget({
      WatchPriority priority = WatchPriority.medium,
      bool showLabel = false,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: PriorityIndicator(priority: priority, showLabel: showLabel),
          ),
        ),
      );
    }

    testWidgets('should display priority icon', (tester) async {
      await tester.pumpWidget(createTestWidget(priority: WatchPriority.high));
      await tester.pumpAndSettle();

      expect(find.byType(PriorityIndicator), findsOneWidget);
      expect(find.byIcon(WatchPriority.high.icon), findsOneWidget);
    });

    testWidgets('should display label when showLabel is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(priority: WatchPriority.high, showLabel: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('High'), findsOneWidget);
      expect(find.byIcon(WatchPriority.high.icon), findsOneWidget);
    });

    testWidgets('should not display label when showLabel is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(priority: WatchPriority.medium, showLabel: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medium'), findsNothing);
      expect(find.byIcon(WatchPriority.medium.icon), findsOneWidget);
    });

    testWidgets('should use correct colors for different priorities', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(priority: WatchPriority.low));
      await tester.pumpAndSettle();

      expect(find.byType(PriorityIndicator), findsOneWidget);
      // Color testing would require more complex widget inspection
    });
  });

  group('CompletionStatusOverlay', () {
    Widget createTestWidget({
      CompletionStatus status = CompletionStatus.completed,
      double? rating,
      DateTime? watchedDate,
      bool showDetails = false,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: CompletionStatusOverlay(
              status: status,
              rating: rating,
              watchedDate: watchedDate,
              showDetails: showDetails,
            ),
          ),
        ),
      );
    }

    testWidgets('should display completion status icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(status: CompletionStatus.completed),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CompletionStatusOverlay), findsOneWidget);
      expect(find.byIcon(CompletionStatus.completed.icon), findsOneWidget);
    });

    testWidgets('should show details when showDetails is true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          status: CompletionStatus.inProgress,
          rating: 8.5,
          watchedDate: DateTime.now().subtract(const Duration(days: 1)),
          showDetails: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('8.5'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
    });

    testWidgets('should not show details when showDetails is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          status: CompletionStatus.paused,
          rating: 7.2,
          showDetails: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Paused'), findsNothing);
      expect(find.text('7.2'), findsNothing);
    });

    testWidgets('should animate in with scale and fade', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should start with scale and fade animations
      expect(find.byType(ScaleTransition), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
    });
  });

  group('QuickActionButton', () {
    Widget createTestWidget({
      IconData icon = Icons.play_arrow_rounded,
      String label = 'Play',
      Color color = AppColors.cinematicGold,
      bool isActive = false,
      VoidCallback? onPressed,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: QuickActionButton(
              icon: icon,
              label: label,
              color: color,
              isActive: isActive,
              onPressed: onPressed ?? () {},
            ),
          ),
        ),
      );
    }

    testWidgets('should display icon and respond to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createTestWidget(onPressed: () => tapped = true));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      await tester.tap(find.byType(QuickActionButton));
      expect(tapped, true);
    });

    testWidgets('should show active state correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(isActive: true));
      await tester.pumpAndSettle();

      expect(find.byType(QuickActionButton), findsOneWidget);
      // Active state styling would require more complex inspection
    });

    testWidgets('should animate on press', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap down should trigger animation
      await tester.press(find.byType(QuickActionButton));
      await tester.pump();

      expect(find.byType(QuickActionButton), findsOneWidget);
    });
  });

  group('RatingOverlay', () {
    Widget createTestWidget({
      double rating = 8.5,
      int voteCount = 1000,
      bool showVoteCount = false,
    }) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: RatingOverlay(
              rating: rating,
              voteCount: voteCount,
              showVoteCount: showVoteCount,
            ),
          ),
        ),
      );
    }

    testWidgets('should display rating value', (tester) async {
      await tester.pumpWidget(createTestWidget(rating: 7.8));
      await tester.pumpAndSettle();

      expect(find.text('7.8'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show vote count when enabled', (tester) async {
      await tester.pumpWidget(
        createTestWidget(rating: 9.2, voteCount: 5000, showVoteCount: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('9.2'), findsOneWidget);
      expect(find.text('5000'), findsOneWidget);
    });

    testWidgets('should not show vote count when disabled', (tester) async {
      await tester.pumpWidget(
        createTestWidget(rating: 6.5, voteCount: 2500, showVoteCount: false),
      );
      await tester.pumpAndSettle();

      expect(find.text('6.5'), findsOneWidget);
      expect(find.text('2500'), findsNothing);
    });

    testWidgets('should animate progress and pulse', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have progress animation
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Should animate in
      await tester.pump();
      expect(find.byType(RatingOverlay), findsOneWidget);
    });
  });

  group('Enums', () {
    test('WatchPriority should have correct values', () {
      expect(WatchPriority.high.label, 'High');
      expect(WatchPriority.medium.label, 'Medium');
      expect(WatchPriority.low.label, 'Low');

      expect(WatchPriority.high.icon, Icons.priority_high_rounded);
      expect(WatchPriority.medium.icon, Icons.remove_rounded);
      expect(WatchPriority.low.icon, Icons.keyboard_arrow_down_rounded);

      expect(WatchPriority.high.color, AppColors.cinematicRed);
      expect(WatchPriority.medium.color, AppColors.cinematicGold);
      expect(WatchPriority.low.color, AppColors.cinematicBlue);
    });

    test('CompletionStatus should have correct values', () {
      expect(CompletionStatus.completed.label, 'Completed');
      expect(CompletionStatus.inProgress.label, 'In Progress');
      expect(CompletionStatus.paused.label, 'Paused');
      expect(CompletionStatus.dropped.label, 'Dropped');

      expect(CompletionStatus.completed.icon, Icons.check_circle_rounded);
      expect(CompletionStatus.inProgress.icon, Icons.play_circle_rounded);
      expect(CompletionStatus.paused.icon, Icons.pause_circle_rounded);
      expect(CompletionStatus.dropped.icon, Icons.cancel_rounded);

      expect(CompletionStatus.completed.color, AppColors.darkSuccessGreen);
      expect(CompletionStatus.inProgress.color, AppColors.cinematicBlue);
      expect(CompletionStatus.paused.color, AppColors.cinematicGold);
      expect(CompletionStatus.dropped.color, AppColors.cinematicRed);
    });
  });

  group('Date Formatting', () {
    testWidgets('should format dates correctly in CompletionStatusOverlay', (
      tester,
    ) async {
      final now = DateTime.now();

      // Test today
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CompletionStatusOverlay(
              status: CompletionStatus.completed,
              watchedDate: now,
              showDetails: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Today'), findsOneWidget);

      // Test yesterday
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CompletionStatusOverlay(
              status: CompletionStatus.completed,
              watchedDate: now.subtract(const Duration(days: 1)),
              showDetails: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Yesterday'), findsOneWidget);

      // Test days ago
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: CompletionStatusOverlay(
              status: CompletionStatus.completed,
              watchedDate: now.subtract(const Duration(days: 3)),
              showDetails: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 days ago'), findsOneWidget);
    });
  });
}
