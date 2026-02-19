import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/components/indicators/animation/loading_animation_controller.dart';
import 'package:rhizu/src/components/indicators/animation/spring_curve.dart';
import 'package:rhizu/src/components/indicators/constants.dart';
import 'package:rhizu/src/components/indicators/painter/morphing_shape_painter.dart';

export 'shapes/shape_type.dart';

/// Defines how the loading indicator is visually contained.
///
/// This affects both the background styling and the color
/// scheme applied to the indicator.
enum Containment {
  /// Simple loading indicator without a container.
  ///
  /// Uses the theme's primary color for the indicator.
  /// No background container is shown.
  simple,

  /// Contained loading indicator with a circular container.
  ///
  /// Uses the theme's primaryContainer color for the background
  /// and onPrimaryContainer color for the indicator.
  contained,
}

/// Loading indicators show the progress for a short wait time.
///
/// The loading indicator displays an animated shape that continuously morphs
/// through a sequence of different shapes while rotating. This creates an
/// "expressive" loading animation that provides visual feedback during
/// short wait periods.
///
/// The indicator is responsive and can be sized between 24dp and 240dp.
/// Several named constructors are provided for common sizes:
/// - [MorphingLI.small] (24dp)
/// - [MorphingLI.medium] (48dp, default)
/// - [MorphingLI.large] (96dp)
/// - [MorphingLI.extraLarge] (144dp)
///
/// Example usage:
/// ```dart
/// // Simple loading indicator (default 48dp)
/// const MorphingLI()
///
/// // Small contained indicator
/// const MorphingLI.small(containment: Containment.contained)
///
/// // Custom size
/// const MorphingLI(size: 64.0)
/// ```
class MorphingLI extends StatefulWidget {
  /// Creates a loading indicator.
  ///
  /// The [containment] parameter controls the visual presentation.
  const MorphingLI({
    super.key,
    this.containment = Containment.simple,
    this.size = LoadingIndicatorConstants.defaultContainerSize,
  });

  /// Creates a small loading indicator (24dp).
  const MorphingLI.small({super.key, this.containment = Containment.simple})
    : size = LoadingIndicatorConstants.minContainerSize;

  /// Creates a medium loading indicator (48dp).
  const MorphingLI.medium({super.key, this.containment = Containment.simple})
    : size = LoadingIndicatorConstants.defaultContainerSize;

  /// Creates a large loading indicator (96dp).
  const MorphingLI.large({super.key, this.containment = Containment.simple})
    : size = 96.0;

  /// Creates an extra large loading indicator (144dp).
  const MorphingLI.extraLarge({
    super.key,
    this.containment = Containment.simple,
  }) : size = 144.0;

  /// How the loading indicator should be visually contained.
  ///
  /// Defaults to [Containment.simple] which shows only the animated shape.
  /// Use [Containment.contained] for a circular container background.
  final Containment containment;

  /// The size of the loading indicator in logical pixels.
  ///
  /// Defaults to [LoadingIndicatorConstants.defaultContainerSize] (48.0).
  /// Must be between [LoadingIndicatorConstants.minContainerSize] (24.0)
  /// and [LoadingIndicatorConstants.maxContainerSize] (240.0).
  final double size;

  @override
  State<MorphingLI> createState() => _MorphingLIState();
}

class _MorphingLIState extends State<MorphingLI> with TickerProviderStateMixin {
  late final LoadingAnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = LoadingAnimationController(
      vsync: this,
      onShapeChange: () => setState(() {}),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isContained = widget.containment == Containment.contained;
    final indicatorColor = isContained
        ? colorScheme.onPrimaryContainer
        : colorScheme.primary;
    final containerColor = isContained
        ? colorScheme.primaryContainer
        : Colors.transparent;

    final clampedSize = widget.size.clamp(
      LoadingIndicatorConstants.minContainerSize,
      LoadingIndicatorConstants.maxContainerSize,
    );

    // RepaintBoundary isolates the animation from parent repaints,
    // preventing unnecessary GPU work when the parent widget changes.
    return RepaintBoundary(
      child: Container(
        width: clampedSize,
        height: clampedSize,
        decoration: BoxDecoration(
          color: containerColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedBuilder(
          animation: _animationController.animation,
          builder: (context, child) {
            final morphProgress = const SpringCurve().transform(
              _animationController.morphValue,
            );

            final globalRotation =
                _animationController.rotationValue * 2 * math.pi;
            final currentStepRotation =
                _animationController.currentIndex * (math.pi / 2);
            final nextStepRotation =
                (_animationController.currentIndex + 1) * (math.pi / 2);
            final stepRotation = lerpDouble(
              currentStepRotation,
              nextStepRotation,
              morphProgress,
            )!;

            return CustomPaint(
              painter: MorphingShapePainter(
                color: indicatorColor,
                currentShape: _animationController.currentShape,
                nextShape: _animationController.nextShape,
                progress: morphProgress,
                rotation: globalRotation + stepRotation,
                scale:
                    clampedSize /
                    LoadingIndicatorConstants.defaultContainerSize,
              ),
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'Morphing Loader')
Widget previewExpressiveLoaderContained() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          // Row 1: Simple (different sizes)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              MorphingLI.small(),
              MorphingLI.medium(),
              MorphingLI.large(),
            ],
          ),
          // Row 2: Contained (different sizes)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              MorphingLI.small(containment: Containment.contained),
              MorphingLI.medium(containment: Containment.contained),
              MorphingLI.large(containment: Containment.contained),
            ],
          ),
        ],
      ),
    ),
  ),
);
