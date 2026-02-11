import 'package:flutter/material.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

class ListDetailLayout extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);

        // Compact/Medium: Single pane
        // Expanded+: Side-by-side
        if (sizeClass == WindowSizeClass.compact ||
            sizeClass == WindowSizeClass.medium) {
          if (isDetailVisible) {
            return detail;
          } else {
            return list;
          }
        } else {
          return Row(
            children: [
              Expanded(flex: listFlex, child: list),
              Expanded(flex: detailFlex, child: detail),
            ],
          );
        }
      },
    );
  }
}
