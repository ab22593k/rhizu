import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/foundation/layout/bento.dart';

void main() {
  group('BentoGrid', () {
    testWidgets('supports padding parameter', (tester) async {
      // THIS WILL FAIL COMPILATION initially because `padding` doesn't exist yet
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BentoGrid(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              itemCount: 4,
              spanBuilder: (index) => const BentoSpan(),
              itemBuilder: (context, index) => Container(
                key: ValueKey('item_$index'),
                color: Colors.red,
              ),
            ),
          ),
        ),
      );

      // We expect the GridView inside BentoGrid to have padding.
      final gridView = tester.widget<GridView>(find.byType(GridView));
      expect(gridView.padding, const EdgeInsets.all(20));
    });
  });

  group('SliverBentoGrid', () {
    testWidgets('supports padding parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverBentoGrid(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(20),
                  itemCount: 4,
                  spanBuilder: (index) => const BentoSpan(),
                  itemBuilder: (context, index) => Container(
                    key: ValueKey('item_$index'),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final paddingList = tester
          .widgetList<SliverPadding>(find.byType(SliverPadding))
          .toList();
      expect(
        paddingList.isNotEmpty,
        isTrue,
        reason: 'Sliver padding not found',
      );
      expect(paddingList.first.padding, const EdgeInsets.all(20));
    });

    test('computes max child bounds without magic numbers', () {
      // If getMaxChildIndexForScrollOffset returns 10000,
      // the framework might over-allocate or report incorrect constraints.

      final delegate = SliverGridDelegateWithBento(
        crossAxisCount: 2,
        spanBuilder: (idx) => const BentoSpan(),
      );

      final layout = delegate.getLayout(
        const SliverConstraints(
          axisDirection: AxisDirection.down,
          growthDirection: GrowthDirection.forward,
          userScrollDirection: ScrollDirection.idle,
          scrollOffset: 0,
          precedingScrollExtent: 0,
          overlap: 0,
          remainingPaintExtent: 1000,
          crossAxisExtent: 400,
          crossAxisDirection: AxisDirection.right,
          viewportMainAxisExtent: 1000,
          remainingCacheExtent: 1000,
          cacheOrigin: 0,
        ),
      );

      // Populate the cache up to index 20
      layout.computeMaxScrollOffset(20);

      final minIdx = layout.getMinChildIndexForScrollOffset(500);

      // Since cell height is >0, scrolling down 500 pixels should mean the min child index
      // is > 0. Currently it returns hardcoded 0. This test will FAIL initially.
      expect(minIdx, greaterThan(0));
    });
  });
}
