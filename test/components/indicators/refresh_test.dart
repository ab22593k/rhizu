import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/indicators/morphing.dart';
import 'package:rhizu/src/ui/components/indicators/refresh.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_registry.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // The contained indicator renders shapes from the SVG assets.
  await ShapeRegistry.prewarm();

  final listView = ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: 12,
    itemBuilder: (context, index) =>
        SizedBox(height: 80, child: Text('Item $index')),
  );

  Widget buildFrame(PullToRefresh widget) =>
      MaterialApp(home: Scaffold(body: widget));

  group('PullToRefresh', () {
    testWidgets('renders the scrollable child with no indicator at rest', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFrame(PullToRefresh(onRefresh: () async {}, child: listView)),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(MorphingLoadingindicator), findsNothing);
    });

    testWidgets('shows a contained indicator while dragging', (tester) async {
      await tester.pumpWidget(
        buildFrame(PullToRefresh(onRefresh: () async {}, child: listView)),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();

      // Spec: the contained loading indicator is used for pull-to-refresh.
      final indicator = tester.widget<MorphingLoadingindicator>(
        find.byType(MorphingLoadingindicator),
      );
      expect(indicator.containment, equals(Containment.contained));

      // The indicator tracks the pull: it fades in and translates below the
      // top edge as the gesture approaches the arming threshold.
      final opacity = tester.widget<AnimatedOpacity>(
        find
            .descendant(
              of: find.byType(PullToRefresh),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      );
      expect(opacity.opacity, greaterThan(0));

      final translates = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byType(PullToRefresh),
              matching: find.byType(Transform),
            ),
          )
          .toList();
      expect(
        translates.any((t) => t.transform.getTranslation().y > 0),
        isTrue,
      );

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('does not refresh below the gesture threshold', (
      tester,
    ) async {
      var refreshCount = 0;
      await tester.pumpWidget(
        buildFrame(
          PullToRefresh(
            onRefresh: () async => refreshCount++,
            child: listView,
          ),
        ),
      );

      // Well below the arming threshold (25% of the 600px viewport).
      await tester.drag(find.byType(ListView), const Offset(0, 80));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(refreshCount, equals(0));
    });

    testWidgets('refreshes only after crossing the gesture threshold', (
      tester,
    ) async {
      var refreshCount = 0;
      await tester.pumpWidget(
        buildFrame(
          PullToRefresh(
            onRefresh: () async => refreshCount++,
            child: listView,
          ),
        ),
      );

      // Past the arming threshold: releasing runs onRefresh.
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(refreshCount, equals(1));
    });

    testWidgets('keeps the indicator visible until refresh completes', (
      tester,
    ) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        buildFrame(
          PullToRefresh(onRefresh: () => completer.future, child: listView),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pump();
      // Let the 150ms snap animation finish so the refresh begins.
      await tester.pump(const Duration(milliseconds: 300));

      // Refresh is in progress: the indicator must still be shown.
      expect(find.byType(MorphingLoadingindicator), findsOneWidget);

      completer.complete();
      await tester.pump(); // Process the completion -> done status.
      await tester.pump(); // Start the indicator fade-out.
      await tester.pump(const Duration(milliseconds: 300)); // Finish it.

      // Refresh finished: the indicator fades out.
      expect(find.byType(MorphingLoadingindicator), findsNothing);
    });

    testWidgets('exposes the refresh lifecycle through onStatusChange', (
      tester,
    ) async {
      final statuses = <RefreshIndicatorStatus?>[];
      final completer = Completer<void>();
      await tester.pumpWidget(
        buildFrame(
          PullToRefresh(
            onRefresh: () => completer.future,
            onStatusChange: statuses.add,
            child: listView,
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pump();
      // Let the 150ms snap animation finish so the refresh begins.
      await tester.pump(const Duration(milliseconds: 300));

      // The framework reports the pull and arming stages. (The `refresh`
      // stage is entered internally without a status callback.)
      expect(statuses, contains(RefreshIndicatorStatus.drag));
      expect(statuses, contains(RefreshIndicatorStatus.armed));
      expect(statuses, contains(RefreshIndicatorStatus.snap));
      expect(statuses, isNot(contains(RefreshIndicatorStatus.done)));

      completer.complete();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(statuses, contains(RefreshIndicatorStatus.done));
    });

    testWidgets('respects a custom indicator', (tester) async {
      await tester.pumpWidget(
        buildFrame(
          PullToRefresh(
            onRefresh: () async {},
            indicator: const MorphingLoadingindicator.extraLarge(
              containment: Containment.contained,
            ),
            child: listView,
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 150));
      await tester.pump();

      final indicator = tester.widget<MorphingLoadingindicator>(
        find.byType(MorphingLoadingindicator),
      );
      expect(indicator.size, equals(144.0));

      await gesture.up();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
