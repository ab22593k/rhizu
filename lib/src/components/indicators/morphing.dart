import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'animation/loading_animation_controller.dart';
import 'animation/spring_curve.dart';
import 'constants.dart';
import 'containment.dart';
import 'painter/morphing_shape_painter.dart';

export 'containment.dart';
export 'shapes/shape_type.dart';

/// Loading indicators show the progress for a short wait time.
///
/// The loading indicator displays an animated shape that continuously morphs
/// through a sequence of different shapes while rotating. This creates an
/// "expressive" loading animation that provides visual feedback during
/// short wait periods.
///
/// Example usage:
/// ```dart
/// // Simple loading indicator
/// const RZLoadingIndicator()
///
/// // Contained loading indicator with background
/// const RZLoadingIndicator(containment: Containment.contained)
/// ```
class MorphingLI extends StatefulWidget {
  /// How the loading indicator should be visually contained.
  ///
  /// Defaults to [Containment.simple] which shows only the animated shape.
  /// Use [Containment.contained] for a circular container background.
  final Containment containment;

  /// Creates a loading indicator.
  ///
  /// The [containment] parameter controls the visual presentation.
  const MorphingLI({super.key, this.containment = Containment.simple});

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

    final bool isContained = widget.containment == Containment.contained;
    final Color indicatorColor = isContained
        ? colorScheme.onPrimaryContainer
        : colorScheme.primary;
    final Color containerColor = isContained
        ? colorScheme.primaryContainer
        : Colors.transparent;

    return Container(
      width: LoadingIndicatorConstants.containerSize,
      height: LoadingIndicatorConstants.containerSize,
      decoration: BoxDecoration(color: containerColor, shape: BoxShape.circle),
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
            ),
          );
        },
      ),
    );
  }
}

@Preview(name: 'Expressive Loader (Contained)')
Widget previewExpressiveLoaderContained() => const Scaffold(
  body: Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 40.0,
      children: [
        MorphingLI(containment: Containment.simple),
        MorphingLI(containment: Containment.contained),
      ],
    ),
  ),
);
