import 'package:flutter/material.dart';

/// A scroll physics that provides a standard momentum fling but with a
/// "tight" stretch back at the boundaries (no bounce/oscillation), keeping the
/// high-end "Lenis" feel at the edges.
class SmoothScrollPhysics extends BouncingScrollPhysics {
  const SmoothScrollPhysics({super.parent});

  @override
  SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get minFlingDistance => 5.0;

  // Tune the spring for the "stretch back" style.
  // Stiff resistance and critical damping (no bounce).
  @override
  SpringDescription get spring => SpringDescription.withDampingRatio(
    mass: 1.0,
    stiffness: 100.0,
    ratio: 2.0,
  );
}

/// A wrapper widget that applies [SmoothScrollPhysics] to its child [Scrollable].
class SmoothScrolling extends StatelessWidget {
  const SmoothScrolling({
    required this.child,
    super.key,
    this.controller,
  });

  final Widget child;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        physics: const SmoothScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
      ),
      child: child,
    );
  }
}
