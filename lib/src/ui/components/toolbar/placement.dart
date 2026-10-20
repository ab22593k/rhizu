import 'package:flutter/material.dart';
import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

/// A wrapper that reconfigures a [RZToolbar] based on the current layout context.
class AdaptiveToolbarPlacement extends StatelessWidget {
  const AdaptiveToolbarPlacement({
    required this.sizeClass,
    required this.toolbar,
    super.key,
    this.isDocked = false,
    this.isVertical = false,
  });

  final WindowSizeClass sizeClass;
  final RZToolbar toolbar;
  final bool isDocked;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    // Reconfigure toolbar for placement. Everything else (actions, FAB,
    // styling, scrollability) is preserved by value semantics.
    final actuallyDocked = isDocked && sizeClass == WindowSizeClass.compact;

    final adaptiveToolbar = toolbar.copyWith(
      type: actuallyDocked ? ToolbarType.docked : ToolbarType.floating,
      layout: isVertical ? ToolbarLayout.vertical : ToolbarLayout.horizontal,
    );

    if (actuallyDocked) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: adaptiveToolbar,
      );
    } else {
      // Floating
      if (isVertical) {
        return Positioned(
          right: 16,
          top: 16,
          bottom: 16,
          child: Center(child: adaptiveToolbar),
        );
      } else {
        return Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Center(child: adaptiveToolbar),
        );
      }
    }
  }
}
