import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/components/indicators/animation/loading_animation_controller.dart';
import 'package:rhizu/src/ui/components/indicators/animation/spring_curve.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/painter/morphing_shape_painter.dart';
import 'package:rhizu/src/ui/styles/motion/fallbacks.dart';

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

/// The state of a morphing loading indicator.
///
/// Controls whether the indicator is actively loading, or has
/// finished with a success or error result.
enum IndicatorState {
  /// The indicator is actively loading (morphing animation plays).
  loading,

  /// The operation completed successfully.
  ///
  /// The morphing shape crossfades into a checkmark icon with
  /// an expressive spring animation.
  success,

  /// The operation failed.
  ///
  /// The morphing shape crossfades into an X/close icon with
  /// an expressive spring animation.
  error,
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
/// - [MorphingLoadingindicator.small] (24dp)
/// - [MorphingLoadingindicator.medium] (48dp, default)
/// - [MorphingLoadingindicator.large] (96dp)
/// - [MorphingLoadingindicator.extraLarge] (144dp)
///
/// Example usage:
/// ```dart
/// // Simple loading indicator (default 48dp)
/// const MorphingLoadingindicator()
///
/// // Transition to success state
/// MorphingLoadingindicator(state: IndicatorState.success)
///
/// // Transition to error state
/// MorphingLoadingindicator(state: IndicatorState.error)
/// ```
class MorphingLoadingindicator extends StatefulWidget {
  /// Creates a loading indicator.
  ///
  /// The [containment] parameter controls the visual presentation.
  /// The [state] parameter controls whether the indicator shows the
  /// loading animation, a success checkmark, or an error X.
  const MorphingLoadingindicator({
    super.key,
    this.containment = Containment.simple,
    this.size = LoadingIndicatorConstants.defaultContainerSize,
    this.state = IndicatorState.loading,
  });

  /// Creates a small loading indicator (24dp).
  const MorphingLoadingindicator.small({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
  }) : size = LoadingIndicatorConstants.minContainerSize;

  /// Creates a medium loading indicator (48dp).
  const MorphingLoadingindicator.medium({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
  }) : size = LoadingIndicatorConstants.defaultContainerSize;

  /// Creates a large loading indicator (96dp).
  const MorphingLoadingindicator.large({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
  }) : size = 96.0;

  /// Creates an extra large loading indicator (144dp).
  const MorphingLoadingindicator.extraLarge({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
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

  /// The current state of the indicator.
  ///
  /// Defaults to [IndicatorState.loading].
  /// When changed to [IndicatorState.success] or [IndicatorState.error],
  /// the morphing animation will crossfade into the appropriate icon.
  final IndicatorState state;

  @override
  State<MorphingLoadingindicator> createState() =>
      _MorphingLoadingindicatorState();
}

class _MorphingLoadingindicatorState extends State<MorphingLoadingindicator>
    with TickerProviderStateMixin {
  late final LoadingAnimationController _animationController;

  /// Pooled Path object to avoid allocation on every frame.
  late final Path _path;

  /// Pooled list of points to avoid allocation on every frame.
  late final List<Offset> _points;

  @override
  void initState() {
    super.initState();
    _path = Path();
    _points = List<Offset>.filled(
      LoadingIndicatorConstants.shapeResolution + 1,
      Offset.zero,
    );
    _animationController = LoadingAnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isContained = widget.containment == Containment.contained;
    final indicatorColor = isContained
        ? colorScheme.onPrimaryContainer
        : colorScheme.primary;
    final containerColor = isContained
        ? colorScheme.primaryContainer
        : Colors.transparent;

    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    final scaledSize = widget.size * scale;
    final clampedSize = scaledSize.clamp(
      LoadingIndicatorConstants.minContainerSize,
      LoadingIndicatorConstants.maxContainerSize,
    );

    // Determine the container color based on state
    final effectiveContainerColor = switch (widget.state) {
      IndicatorState.loading => containerColor,
      IndicatorState.success => colorScheme.primaryContainer,
      IndicatorState.error => colorScheme.errorContainer,
    };

    // RepaintBoundary isolates the animation from parent repaints,
    // preventing unnecessary GPU work when the parent widget changes.
    return RepaintBoundary(
      child: Container(
        width: clampedSize,
        height: clampedSize,
        decoration: BoxDecoration(
          color: effectiveContainerColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: MotionFallbacks.expressiveFastSpatialDuration,
          switchInCurve: MotionFallbacks.expressiveFastSpatial,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: widget.state == IndicatorState.loading
              ? _buildMorphingAnimation(indicatorColor, clampedSize)
              : _buildResultIcon(widget.state, clampedSize),
        ),
      ),
    );
  }

  Widget _buildMorphingAnimation(Color indicatorColor, double clampedSize) {
    return AnimatedBuilder(
      key: const ValueKey(IndicatorState.loading),
      animation: _animationController.animation,
      builder: (context, child) {
        final morphProgress = const SpringCurve().transform(
          _animationController.morphValue,
        );

        final globalRotation = _animationController.rotationValue * 2 * math.pi;
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
            path: _path,
            points: _points,
            scale: clampedSize / LoadingIndicatorConstants.defaultContainerSize,
          ),
        );
      },
    );
  }

  Widget _buildResultIcon(IndicatorState state, double clampedSize) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconData = state == IndicatorState.success
        ? Icons.check_rounded
        : Icons.close_rounded;
    final iconColor = state == IndicatorState.success
        ? colorScheme.onPrimaryContainer
        : colorScheme.onErrorContainer;

    return Icon(
      key: ValueKey(state),
      iconData,
      size: clampedSize * 0.5,
      color: iconColor,
    );
  }
}

@Preview(name: 'Morphing Loading indicator', size: Size.fromHeight(500))
Widget previewExpressiveLoaderContained() => MaterialApp(
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
              const MorphingLoadingindicator.small(),
              const MorphingLoadingindicator.medium(),
              const MorphingLoadingindicator.large(),
              FutureBuilder<IndicatorState>(
                future: Future.delayed(
                  const Duration(seconds: 3),
                  () => IndicatorState.error,
                ),
                builder: (context, snapshot) {
                  final state = snapshot.connectionState == ConnectionState.done
                      ? IndicatorState.error
                      : IndicatorState.loading;
                  return MorphingLoadingindicator.large(state: state);
                },
              ),
            ],
          ),
          // Row 2: Contained (different sizes)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              const MorphingLoadingindicator.small(
                containment: Containment.contained,
              ),
              const MorphingLoadingindicator.medium(
                containment: Containment.contained,
              ),
              const MorphingLoadingindicator.large(
                containment: Containment.contained,
              ),
              FutureBuilder<IndicatorState>(
                future: Future.delayed(
                  const Duration(seconds: 3),
                  () => IndicatorState.success,
                ),
                builder: (context, snapshot) {
                  final state = snapshot.connectionState == ConnectionState.done
                      ? IndicatorState.success
                      : IndicatorState.loading;
                  return MorphingLoadingindicator.large(state: state);
                },
              ),
            ],
          ),
          // Row 3: Success state
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
          ),
        ],
      ),
    ),
  ),
);
