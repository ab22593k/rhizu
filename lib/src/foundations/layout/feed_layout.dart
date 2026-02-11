import 'package:flutter/material.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

class FeedLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);
        int crossAxisCount;

        switch (sizeClass) {
          case WindowSizeClass.compact:
            crossAxisCount = 1;
          case WindowSizeClass.medium:
            crossAxisCount = 1; // Or 2 depending on density
          case WindowSizeClass.expanded:
            crossAxisCount = 2;
          case WindowSizeClass.large:
            crossAxisCount = 3;
          case WindowSizeClass.extraLarge:
            crossAxisCount = 4;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
