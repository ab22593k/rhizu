import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:rhizu/src/ui/foundation/layout/bento_delegate.dart'
    show BentoPacker, BentoSpanBuilder;

export 'bento_delegate.dart' show BentoSpan, BentoSpanBuilder;

/// A custom layout delegate that packs bento tiles into columns.
class _BentoGridLayout extends SliverGridLayout {
  _BentoGridLayout({
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.crossAxisExtent,
    required this.packer,
  }) : _cellExtent = math.max(
         0.0,
         (crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1)) /
             crossAxisCount,
       );

  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double crossAxisExtent;
  final BentoPacker packer;

  final double _cellExtent;

  @override
  SliverGridGeometry getGeometryForChildIndex(int index) {
    final tile = packer.tileAt(index);

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
    if (packer.geometryCache.isEmpty) return 0;

    var fallbackMin = 0;
    // Iterate backwards starting from the highest constructed index
    for (var i = packer.geometryCache.keys.reduce(math.max); i >= 0; i--) {
      final tile = packer.geometryCache[i];
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
    packer.tileAt(childCount - 1);

    // Find absolute highest column
    var maxHeight = 0;
    for (final height in packer.columnHeights) {
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
  }) : assert(crossAxisCount > 0, 'crossAxisCount must be greater than 0'),
       _packer = BentoPacker(
         crossAxisCount: crossAxisCount,
         spanBuilder: spanBuilder,
       );

  final int crossAxisCount;
  final BentoSpanBuilder spanBuilder;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  final BentoPacker _packer;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    return _BentoGridLayout(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      crossAxisExtent: constraints.crossAxisExtent,
      packer: _packer,
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithBento oldDelegate) {
    if (oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.spanBuilder != spanBuilder) {
      _packer.clear();
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
