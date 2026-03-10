import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widget_previews.dart';

/// Defines the span of a tile in a Bento Grid.
@immutable
class BentoSpan {
  const BentoSpan({this.crossAxis = 1, this.mainAxis = 1});

  /// How many columns this tile covers.
  final int crossAxis;

  /// How many rows (in terms of grid blocks) this tile covers.
  final int mainAxis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BentoSpan &&
          runtimeType == other.runtimeType &&
          crossAxis == other.crossAxis &&
          mainAxis == other.mainAxis;

  @override
  int get hashCode => crossAxis.hashCode ^ mainAxis.hashCode;
}

/// A function to provide a [BentoSpan] for a given index.
typedef BentoSpanBuilder = BentoSpan Function(int index);

// --- Layout Logic ---

class _BentoTileGeometry {
  const _BentoTileGeometry({
    required this.crossAxisIndex,
    required this.mainAxisIndex,
    required this.crossAxisSpan,
    required this.mainAxisSpan,
  });

  final int crossAxisIndex;
  final int mainAxisIndex;
  final int crossAxisSpan;
  final int mainAxisSpan;
}

/// A custom layout delegate that packs bento tiles into columns.
class _BentoGridLayout extends SliverGridLayout {
  _BentoGridLayout({
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.spanBuilder,
    required this.crossAxisExtent,
    required this.geometryCache,
    required this.columnHeights,
  }) : _cellExtent = math.max(
         0.0,
         (crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1)) /
             crossAxisCount,
       );

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final BentoSpanBuilder spanBuilder;
  final double crossAxisExtent;

  final double _cellExtent;

  final Map<int, _BentoTileGeometry> geometryCache;
  final List<int> columnHeights; // Tracking height in 'blocks'

  _BentoTileGeometry _getTile(int index) {
    if (geometryCache.containsKey(index)) {
      return geometryCache[index]!;
    }

    if (columnHeights.isEmpty) {
      columnHeights.addAll(List.filled(crossAxisCount, 0));
    }

    // Compute from the highest cached index + 1 up to 'index'
    final startIndex = geometryCache.isEmpty
        ? 0
        : geometryCache.keys.reduce(math.max) + 1;

    for (var i = startIndex; i <= index; i++) {
      final span = spanBuilder(i);
      // Ensure tiles don't exceed max columns
      final int crossSpan = math.min(span.crossAxis, crossAxisCount);
      final mainSpan = span.mainAxis;

      var startMain = -1;
      var startCross = -1;

      // Find the earliest row where crossSpan fits seamlessly
      var currentY = 0;
      var found = false;

      // Very basic packing: scan row by row, from left to right.
      while (!found) {
        for (var x = 0; x <= crossAxisCount - crossSpan; x++) {
          var fits = true;
          for (var c = x; c < x + crossSpan; c++) {
            if (columnHeights[c] > currentY) {
              fits = false;
              break;
            }
          }
          if (fits) {
            startMain = currentY;
            startCross = x;
            found = true;
            break;
          }
        }
        if (!found) currentY++;
      }

      // Place tile and update column heights
      for (var c = startCross; c < startCross + crossSpan; c++) {
        columnHeights[c] = startMain + mainSpan;
      }

      geometryCache[i] = _BentoTileGeometry(
        crossAxisIndex: startCross,
        mainAxisIndex: startMain,
        crossAxisSpan: crossSpan,
        mainAxisSpan: mainSpan,
      );
    }

    return geometryCache[index]!;
  }

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final tile = _getTile(index);

    final mainAxisOffset = tile.mainAxisIndex * (_cellExtent + mainAxisSpacing);
    final crossAxisOffset =
        tile.crossAxisIndex * (_cellExtent + crossAxisSpacing);

    final mainAxisExtent =
        tile.mainAxisSpan * _cellExtent +
        (tile.mainAxisSpan - 1) * mainAxisSpacing;
    final tileCrossAxisExtent =
        tile.crossAxisSpan * _cellExtent +
        (tile.crossAxisSpan - 1) * crossAxisSpacing;

    return SliverGridGeometry(
      scrollOffset: mainAxisOffset,
      crossAxisOffset: crossAxisOffset,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: tileCrossAxisExtent,
    );
  }

  @override
  int getMinChildIndexForScrollOffset(double scrollOffset) {
    if (_cellExtent == 0) return 0;

    // Convert scroll offset to an approximate block level.
    // This isn't perfect since tiles can span, but we walk backward in the cache.
    if (geometryCache.isEmpty) return 0;

    var fallbackMin = 0;
    // Iterate backwards starting from the highest constructed index
    for (var i = geometryCache.keys.reduce(math.max); i >= 0; i--) {
      final tile = geometryCache[i];
      if (tile == null) continue;

      final tileBottomOffset =
          (tile.mainAxisIndex + tile.mainAxisSpan) *
          (_cellExtent + mainAxisSpacing);

      // If we found a tile whose bottom edge is above the current scroll offset,
      // it means this tile is safely out of view. We can start considering children near here.
      if (tileBottomOffset <= scrollOffset) {
        fallbackMin = i;
        break;
      }
    }

    return fallbackMin;
  }

  @override
  int getMaxChildIndexForScrollOffset(double scrollOffset) {
    return 10000;
  }

  @override
  double computeMaxScrollOffset(int childCount) {
    if (childCount == 0) return 0.0;

    // Calculate layout for all items to find true max height
    _getTile(childCount - 1);

    // Find absolute highest column
    var maxHeight = 0;
    for (final height in columnHeights) {
      if (height > maxHeight) maxHeight = height;
    }

    if (maxHeight == 0) return 0.0;

    return maxHeight * (_cellExtent + mainAxisSpacing) - mainAxisSpacing;
  }
}

class SliverGridDelegateWithBento extends SliverGridDelegate {
  SliverGridDelegateWithBento({
    required this.crossAxisCount,
    required this.spanBuilder,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
  }) : assert(crossAxisCount > 0, 'crossAxisCount must be greater than 0');

  final int crossAxisCount;
  final BentoSpanBuilder spanBuilder;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  final Map<int, _BentoTileGeometry> _geometryCache = {};
  final List<int> _columnHeights = [];

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    return _BentoGridLayout(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      spanBuilder: spanBuilder,
      crossAxisExtent: constraints.crossAxisExtent,
      geometryCache: _geometryCache,
      columnHeights: _columnHeights,
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithBento oldDelegate) {
    if (oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.spanBuilder != spanBuilder) {
      _geometryCache.clear();
      _columnHeights.clear();
      return true;
    }
    return false;
  }
}

// --- High-Level Layout Widgets ---

/// A static-sized Bento Grid layout, perfect for non-scrolling dashboards
/// or single pages. Uses [GridView] under the hood but with physics disabled.
class BentoGrid extends StatelessWidget {
  const BentoGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.spanBuilder,
    super.key,
    this.padding,
    this.crossAxisCount = 4,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
  });

  /// The number of children in the grid.
  final int itemCount;

  /// Builds the children widgets.
  final IndexedWidgetBuilder itemBuilder;

  /// Defines the span layout for each child index.
  final BentoSpanBuilder spanBuilder;

  /// Optional padding around the grid.
  final EdgeInsetsGeometry? padding;

  /// Base number of columns.
  final int crossAxisCount;

  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    // Uses standard GridView with ShrinkWrap to render inside standard flex layouts.
    return GridView.builder(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithBento(
        crossAxisCount: crossAxisCount,
        spanBuilder: spanBuilder,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// A lazy-loading Bento Grid implemented as a sliver, suitable for placing
/// inside a [CustomScrollView] with potentially hundreds of items.
class SliverBentoGrid extends StatelessWidget {
  const SliverBentoGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.spanBuilder,
    super.key,
    this.padding,
    this.crossAxisCount = 4,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final BentoSpanBuilder spanBuilder;
  final EdgeInsetsGeometry? padding;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    Widget sliver = SliverGrid(
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
      ),
      gridDelegate: SliverGridDelegateWithBento(
        crossAxisCount: crossAxisCount,
        spanBuilder: spanBuilder,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
    );

    if (padding != null) {
      sliver = SliverPadding(padding: padding!, sliver: sliver);
    }

    return sliver;
  }
}

@Preview(name: 'Bento Grid Dashboard')
Widget bentoGridDashboard() {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: BentoGrid(
        itemCount: 6,
        itemBuilder: (context, index) {
          final colors = [
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.indigo,
            Colors.red,
            Colors.green,
          ];
          return Container(
            decoration: BoxDecoration(
              color: colors[index % colors.length].withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Tile $index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        spanBuilder: (index) {
          switch (index) {
            case 0:
              return const BentoSpan(crossAxis: 2, mainAxis: 2);
            case 1:
              return const BentoSpan(crossAxis: 2);
            case 2:
              return const BentoSpan(mainAxis: 2);
            default:
              return const BentoSpan();
          }
        },
      ),
    ),
  );
}
