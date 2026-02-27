import 'package:flutter/material.dart';
import 'package:rhizu/src/components/toolbars/toolbars.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

/// A wrapper that reconfigures a [Toolbar] based on the current layout context.
class AdaptiveToolbarPlacement extends StatelessWidget {
  const AdaptiveToolbarPlacement({
    required this.sizeClass,
    required this.toolbar,
    super.key,
    this.isDocked = false,
    this.isVertical = false,
  });

  final WindowSizeClass sizeClass;
  final Toolbar toolbar;
  final bool isDocked;
  final bool isVertical;

  @override
  Widget build(BuildContext context) {
    // Reconfigure toolbar for placement
    final actuallyDocked = isDocked && sizeClass == WindowSizeClass.compact;

    final adaptiveToolbar = Toolbar(
      type: actuallyDocked ? ToolbarType.docked : ToolbarType.floating,
      layout: isVertical ? ToolbarLayout.vertical : ToolbarLayout.horizontal,
      style: toolbar.style,
      leading: toolbar.leading,
      trailing: toolbar.trailing,
      fab: toolbar.fab,
      centerTitle: toolbar.centerTitle,
      scrollable: toolbar.scrollable,
      backgroundColor: toolbar.backgroundColor,
      elevation: toolbar.elevation,
      padding: toolbar.padding,
      borderRadius: toolbar.borderRadius,
      shape: toolbar.shape,
      children: toolbar.children,
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
