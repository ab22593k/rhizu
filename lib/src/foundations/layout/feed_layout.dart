import 'package:flutter/material.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

/// A feed layout that adapts column count based on window size.
///
/// Uses cached calculations to avoid recomputing window size class
/// on every layout pass, improving scroll performance.
class FeedLayout extends StatefulWidget {
  const FeedLayout({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.childAspectRatio = 0.8,
  });
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double childAspectRatio;

  @override
  State<FeedLayout> createState() => _FeedLayoutState();
}

class _FeedLayoutState extends State<FeedLayout> {
  late int? _cachedCrossAxisCount;
  double? _cachedWidth;

  /// Calculates cross-axis count with caching to avoid recomputation.
  int _getCrossAxisCount(double width) {
    // Return cached value if width hasn't changed significantly
    if (_cachedWidth != null && width == _cachedWidth) {
      return _cachedCrossAxisCount!;
    }

    _cachedWidth = width;
    final sizeClass = WindowSizeClass.fromWidth(width);

    switch (sizeClass) {
      case WindowSizeClass.compact:
        _cachedCrossAxisCount = 1;
      case WindowSizeClass.medium:
        _cachedCrossAxisCount = 1; // Or 2 depending on density
      case WindowSizeClass.expanded:
        _cachedCrossAxisCount = 2;
      case WindowSizeClass.large:
        _cachedCrossAxisCount = 3;
      case WindowSizeClass.extraLarge:
        _cachedCrossAxisCount = 4;
    }

    return _cachedCrossAxisCount!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: widget.childAspectRatio,
          ),
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
        );
      },
    );
  }
}
