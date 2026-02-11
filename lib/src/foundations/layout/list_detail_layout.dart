import 'package:flutter/material.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

/// A list-detail layout that shows either single or dual pane based on window size.
///
/// Uses cached calculations to avoid recomputing window size class
/// on every layout pass.
class ListDetailLayout extends StatefulWidget {
  const ListDetailLayout({
    required this.list,
    required this.detail,
    super.key,
    this.isDetailVisible = false,
    this.listFlex = 1,
    this.detailFlex = 1,
  });
  final Widget list;
  final Widget detail;
  final bool isDetailVisible;
  final int listFlex;
  final int detailFlex;

  @override
  State<ListDetailLayout> createState() => _ListDetailLayoutState();
}

class _ListDetailLayoutState extends State<ListDetailLayout> {
  late bool? _cachedIsCompact;
  double? _cachedWidth;

  /// Determines if layout should show single pane with caching.
  bool _isCompact(double width) {
    if (_cachedWidth != null && width == _cachedWidth) {
      return _cachedIsCompact!;
    }

    _cachedWidth = width;
    final sizeClass = WindowSizeClass.fromWidth(width);
    _cachedIsCompact =
        sizeClass == WindowSizeClass.compact ||
        sizeClass == WindowSizeClass.medium;

    return _cachedIsCompact!;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Compact/Medium: Single pane
        // Expanded+: Side-by-side
        if (_isCompact(constraints.maxWidth)) {
          if (widget.isDetailVisible) {
            return widget.detail;
          } else {
            return widget.list;
          }
        } else {
          return Row(
            children: [
              Expanded(flex: widget.listFlex, child: widget.list),
              Expanded(flex: widget.detailFlex, child: widget.detail),
            ],
          );
        }
      },
    );
  }
}
