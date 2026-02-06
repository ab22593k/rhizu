import 'package:flutter/material.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

class SupportingPaneLayout extends StatelessWidget {

  const SupportingPaneLayout({
    required this.main, required this.supporting, super.key,
    this.mainFlex = 2,
    this.supportingFlex = 1,
  });
  final Widget main;
  final Widget supporting;
  final int mainFlex;
  final int supportingFlex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizeClass = WindowSizeClass.fromWidth(constraints.maxWidth);

        if (sizeClass == WindowSizeClass.compact ||
            sizeClass == WindowSizeClass.medium) {
          return main;
        } else {
          return Row(
            children: [
              Expanded(flex: mainFlex, child: main),
              Expanded(flex: supportingFlex, child: supporting),
            ],
          );
        }
      },
    );
  }
}
