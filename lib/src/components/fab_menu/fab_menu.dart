import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Data class for a menu item in the FAB Menu.
class FabMenuItem {
  const FabMenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
}

/// A widget that renders a single menu item.
class FabMenuItemWidget extends StatelessWidget {
  const FabMenuItemWidget({
    required this.item,
    required this.animation,
    required this.onItemPressed,
    required this.index,
    super.key,
  });

  final FabMenuItem item;
  final Animation<double> animation;
  final VoidCallback onItemPressed;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(width: 12),
            FloatingActionButton.small(
              heroTag: 'fab_menu_item_$index',
              onPressed: () {
                item.onPressed();
                onItemPressed(); // Close the menu
              },
              elevation: 2, // Shadow when expanded
              child: item.icon,
            ),
          ],
        ),
      ),
    );
  }
}

/// Material 3 Expressive FAB Menu.
///
/// Displays a floating action button that toggles a menu of related actions.
class FabMenu extends StatefulWidget {
  const FabMenu({
    required this.children,
    super.key,
    this.alignment = Alignment.bottomRight,
  });

  final List<FabMenuItem> children;
  final Alignment alignment;

  @override
  State<FabMenu> createState() => _FabMenuState();
}

class _FabMenuState extends State<FabMenu> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Expansion duration
      reverseDuration: const Duration(milliseconds: 250), // Collapse duration
      vsync: this,
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, // Rotation easing
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.alignment,
      children: [
        // Dimmer/Backdrop (optional, but good for focus)
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),

        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end, // Align items to end
            children: [
              // Menu Items
              ...List.generate(widget.children.length, (index) {
                // Stagger logic
                // Reverse index for collapse so bottom items disappear first?
                // Spec: "Stagger delay 30-50ms".
                // Index 0 is top item? No, usually FAB is at bottom, so index 0 is closest to FAB?
                // Let's assume children[0] is bottom-most item above FAB.

                final intervalStart = 0.0 + (index * 0.1);
                final intervalEnd = 0.6 + (index * 0.1);

                final itemAnimation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(
                    math.min(intervalStart, 0.8),
                    math.min(intervalEnd, 1.0),
                    curve: Curves.easeInOutCubicEmphasized,
                  ),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12), // Spacing
                  child: FabMenuItemWidget(
                    item: widget.children[index], // Pass item
                    animation: itemAnimation,
                    onItemPressed: _toggleMenu,
                    index: index,
                  ),
                );
              }),

              // Main FAB
              FloatingActionButton(
                key: const ValueKey('fab_menu_toggle'),
                heroTag: 'fab_menu_main',
                onPressed: _toggleMenu,
                child: RotationTransition(
                  turns: _rotateAnimation,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Preview ---

@Preview(name: 'FabMenus', size: Size.fromHeight(280))
Widget fabMenuPreview() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      floatingActionButton: FabMenu(
        children: [
          FabMenuItem(
            label: 'Copy',
            icon: const Icon(Icons.content_copy),
            onPressed: () {},
          ),
          FabMenuItem(
            label: 'Paste',
            icon: const Icon(Icons.content_paste),
            onPressed: () {},
          ),
          FabMenuItem(
            label: 'Cut',
            icon: const Icon(Icons.content_cut),
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}
