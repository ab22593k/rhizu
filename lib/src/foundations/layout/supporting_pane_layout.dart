import 'package:flutter/material.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

/// A supporting pane layout that shows supporting content based on window size.
///
/// Uses cached calculations to avoid recomputing window size class
/// on every layout pass.
class SupportingPaneLayout extends StatefulWidget {
  const SupportingPaneLayout({
    required this.main,
    required this.supporting,
    super.key,
    this.mainFlex = 2,
    this.supportingFlex = 1,
  });
  final Widget main;
  final Widget supporting;
  final int mainFlex;
  final int supportingFlex;

  @override
  State<SupportingPaneLayout> createState() => _SupportingPaneLayoutState();
}

class _SupportingPaneLayoutState extends State<SupportingPaneLayout> {
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
        if (_isCompact(constraints.maxWidth)) {
          return widget.main;
        } else {
          return Row(
            children: [
              Expanded(flex: widget.mainFlex, child: widget.main),
              Expanded(flex: widget.supportingFlex, child: widget.supporting),
            ],
          );
        }
      },
    );
  }
}
