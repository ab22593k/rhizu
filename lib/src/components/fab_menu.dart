import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rhizu/src/styles/shapes/tokens.dart';

/// Data class for a menu item in the FAB Menu.
class RZFabMenuItem {
  const RZFabMenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
}

/// Configuration for an optional built-in FAB menu on an `RZToolbar`.
///
/// Pass this to `RZToolbar.fabMenu` to declaratively configure a FAB menu
/// without manually composing an [RZFabMenu] widget.
class RZFabMenuConfig {
  const RZFabMenuConfig({
    required this.items,
    this.icon,
    this.alignment = Alignment.bottomRight,
  });

  /// The menu items displayed when the FAB is expanded.
  final List<RZFabMenuItem> items;

  /// Custom icon for the main FAB. Defaults to a rotating [Icons.add].
  final Widget? icon;

  /// Alignment within the toolbar's parent stack.
  final Alignment alignment;
}

/// A widget that renders a single menu item.
class RZFabMenuItemWidget extends StatelessWidget {
  const RZFabMenuItemWidget({
    required this.item,
    required this.animation,
    required this.onItemPressed,
    required this.index,
    super.key,
  });

  final RZFabMenuItem item;
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: ShapeTokens.borderRadiusMedium,
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

/// Expressive FAB Menu.
///
/// Displays a floating action button that toggles a menu of related actions.
/// Menu items are rendered in an [Overlay] so the FAB itself is the only widget
/// that occupies space in the layout tree — ideal for embedding in toolbars.
class RZFabMenu extends StatefulWidget {
  const RZFabMenu({
    required this.children,
    super.key,
    this.alignment = Alignment.bottomRight,
    this.icon,
  });

  final List<RZFabMenuItem> children;
  final Alignment alignment;

  /// Custom icon for the main FAB toggle.
  /// Defaults to a rotating [Icons.add] icon.
  final Widget? icon;

  @override
  State<RZFabMenu> createState() => _RZFabMenuState();
}

class _RZFabMenuState extends State<RZFabMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  bool _isExpanded = false;

  final _layerLink = LayerLink();
  final _overlayController = OverlayPortalController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimationDurations();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
  }

  void _updateAnimationDurations() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    // md.sys.motion.duration-medium: 300ms enter / 250ms exit
    final forwardMs = reduceMotion ? 150 : 300;
    final reverseMs = reduceMotion ? 125 : 250;
    _controller.duration = Duration(milliseconds: forwardMs);
    _controller.reverseDuration = Duration(milliseconds: reverseMs);
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
        _overlayController.show();
        _controller.forward();
      } else {
        _controller.reverse().then((_) {
          if (mounted && !_isExpanded) {
            _overlayController.hide();
          }
        });
      }
    });
  }

  Widget _buildOverlay(BuildContext context) {
    return Stack(
      children: [
        // Full-screen dismiss scrim
        Positioned.fill(
          child: GestureDetector(
            key: const ValueKey('fab_menu_scrim'),
            onTap: _toggleMenu,
            behavior: HitTestBehavior.translucent,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),

        // Menu items positioned above the FAB
        CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.topRight,
          followerAnchor: Alignment.bottomRight,
          offset: const Offset(0, -12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.children.length, (index) {
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
                padding: const EdgeInsets.only(bottom: 12),
                child: RZFabMenuItemWidget(
                  item: widget.children[index],
                  animation: itemAnimation,
                  onItemPressed: _toggleMenu,
                  index: index,
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // The FAB is the only widget that takes layout space.
    // Menu items render in an overlay via OverlayPortal.
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: _buildOverlay,
        child: FloatingActionButton(
          key: const ValueKey('fab_menu_toggle'),
          heroTag: 'fab_menu_main',
          onPressed: _toggleMenu,
          child: RotationTransition(
            turns: _rotateAnimation,
            child: widget.icon ?? const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
