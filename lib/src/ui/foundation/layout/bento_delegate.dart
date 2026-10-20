import 'dart:math' as math;

import 'package:flutter/foundation.dart';

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

/// The resolved grid position and span of one bento tile.
@immutable
class BentoTileGeometry {
  const BentoTileGeometry({
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

/// Packs bento tiles into columns, row by row, from left to right.
///
/// The packer is stateful: it caches the geometry of every tile it has
/// resolved so later tiles can be placed without recomputing earlier ones.
/// Call [clear] whenever the column count or span builder changes.
class BentoPacker {
  BentoPacker({
    required this.crossAxisCount,
    required this.spanBuilder,
  }) : assert(crossAxisCount > 0, 'crossAxisCount must be greater than 0');

  final int crossAxisCount;
  final BentoSpanBuilder spanBuilder;

  final Map<int, BentoTileGeometry> _geometryCache = {};
  final List<int> _columnHeights = [];

  /// The tiles resolved so far, keyed by child index.
  Map<int, BentoTileGeometry> get geometryCache => _geometryCache;

  /// The height of each column in grid blocks.
  List<int> get columnHeights => _columnHeights;

  /// Resolves the geometry for the tile at [index], packing it into the first
  /// free position that fits its span.
  BentoTileGeometry tileAt(int index) {
    final cached = _geometryCache[index];
    if (cached != null) return cached;

    if (_columnHeights.isEmpty) {
      _columnHeights.addAll(List.filled(crossAxisCount, 0));
    }

    // Compute from the highest cached index + 1 up to 'index'.
    final startIndex = _geometryCache.isEmpty
        ? 0
        : _geometryCache.keys.reduce(math.max) + 1;

    for (var i = startIndex; i <= index; i++) {
      final span = spanBuilder(i);
      // Ensure tiles don't exceed the available columns.
      final crossSpan = math.min(span.crossAxis, crossAxisCount);
      final mainSpan = span.mainAxis;

      var startMain = -1;
      var startCross = -1;

      // Find the earliest row where crossSpan fits seamlessly.
      var currentY = 0;
      var found = false;

      // Very basic packing: scan row by row, from left to right.
      while (!found) {
        for (var x = 0; x <= crossAxisCount - crossSpan; x++) {
          var fits = true;
          for (var c = x; c < x + crossSpan; c++) {
            if (_columnHeights[c] > currentY) {
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

      // Place the tile and update column heights.
      for (var c = startCross; c < startCross + crossSpan; c++) {
        _columnHeights[c] = startMain + mainSpan;
      }

      _geometryCache[i] = BentoTileGeometry(
        crossAxisIndex: startCross,
        mainAxisIndex: startMain,
        crossAxisSpan: crossSpan,
        mainAxisSpan: mainSpan,
      );
    }

    return _geometryCache[index]!;
  }

  /// Drops every cached tile and column height.
  void clear() {
    _geometryCache.clear();
    _columnHeights.clear();
  }
}
