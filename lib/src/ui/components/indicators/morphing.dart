import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/components/indicators/animation/loading_animation_controller.dart';
import 'package:rhizu/src/ui/components/indicators/animation/spring_curve.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/painter/morphing_shape_painter.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_registry.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_type.dart';
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
/// By default the indicator morphs through [defaultShapeSequence] (7 shapes).
/// Pass [shapeSequence] to pick any subset of the 35 [ShapeType]s the
/// indicator should morph through, in any order.
///
/// Example usage:
/// ```dart
/// // Simple loading indicator (default 48dp, default shape sequence)
/// const MorphingLoadingindicator()
///
/// // Morph through a custom set of shapes
/// const MorphingLoadingindicator(
///   shapeSequence: [
///     ShapeType.heart,
///     ShapeType.diamond,
///     ShapeType.clover4,
///     ShapeType.flower,
///   ],
/// )
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
  /// The [shapeSequence] parameter controls which [ShapeType]s the indicator
  /// morphs through while loading.
  const MorphingLoadingindicator({
    super.key,
    this.containment = Containment.simple,
    this.size = LoadingIndicatorConstants.defaultContainerSize,
    this.state = IndicatorState.loading,
    this.shapeSequence = defaultShapeSequence,
  });

  /// Creates a small loading indicator (24dp).
  const MorphingLoadingindicator.small({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
    this.shapeSequence = defaultShapeSequence,
  }) : size = LoadingIndicatorConstants.minContainerSize;

  /// Creates a medium loading indicator (48dp).
  const MorphingLoadingindicator.medium({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
    this.shapeSequence = defaultShapeSequence,
  }) : size = LoadingIndicatorConstants.defaultContainerSize;

  /// Creates a large loading indicator (96dp).
  const MorphingLoadingindicator.large({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
    this.shapeSequence = defaultShapeSequence,
  }) : size = 96.0;

  /// Creates an extra large loading indicator (144dp).
  const MorphingLoadingindicator.extraLarge({
    super.key,
    this.containment = Containment.simple,
    this.state = IndicatorState.loading,
    this.shapeSequence = defaultShapeSequence,
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
  ///
  /// The size is independent of the ambient text scale factor; increasing
  /// the system font size does not grow the indicator.
  final double size;

  /// The current state of the indicator.
  ///
  /// Defaults to [IndicatorState.loading].
  /// When changed to [IndicatorState.success] or [IndicatorState.error],
  /// the morphing animation will crossfade into the appropriate icon.
  final IndicatorState state;

  /// The sequence of [ShapeType]s the indicator morphs through.
  ///
  /// Defaults to [defaultShapeSequence]. Any subset of the 35 available
  /// shapes can be supplied, in any order. An empty list falls back to the
  /// default sequence. Changes to this value while loading take effect on
  /// the next rebuild.
  final List<ShapeType> shapeSequence;

  @override
  State<MorphingLoadingindicator> createState() =>
      _MorphingLoadingindicatorState();
}

class _MorphingLoadingindicatorState extends State<MorphingLoadingindicator>
    with TickerProviderStateMixin {
  static final _springCurve = SpringCurve();

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
      shapeSequence: widget.shapeSequence,
      // Start stopped; didChangeDependencies applies the ambient
      // reduced-motion preference before the first build.
      animationsEnabled: false,
    );

    // Shape geometry lives in the SVG assets; load them so the first
    // frame can paint the morphing shape instead of the placeholder.
    unawaited(_ensureShapesLoaded());
  }

  @override
  void didUpdateWidget(covariant MorphingLoadingindicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.shapeSequence, widget.shapeSequence)) {
      _animationController.setShapeSequence(widget.shapeSequence);
    }
  }

  Future<void> _ensureShapesLoaded() async {
    try {
      await ShapeRegistry.prewarm();
    } on Object catch (error) {
      // Shape assets ship with the package, so a failure is not expected;
      // stay on the placeholder rather than crashing with an unhandled error.
      debugPrint('Failed to load shape assets: $error');
      return;
    }
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController.setAnimationsEnabled(
      enabled: !MediaQuery.disableAnimationsOf(context),
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

    final (indicatorColor, containerColor) = switch (widget.containment) {
      Containment.simple => (colorScheme.primary, Colors.transparent),
      Containment.contained => (
        colorScheme.onPrimaryContainer,
        colorScheme.primaryContainer,
      ),
    };

    // The indicator is sized in logical pixels and deliberately ignores the
    // ambient text scale factor: typography settings are an accessibility
    // preference, not a window breakpoint (spec: 24-240dp by placement).
    final clampedSize = widget.size.clamp(
      LoadingIndicatorConstants.minContainerSize,
      LoadingIndicatorConstants.maxContainerSize,
    );

    // Determine the container color based on state
    final effectiveContainerColor = switch (widget.state) {
      IndicatorState.loading => containerColor,
      IndicatorState.success => colorScheme.primaryContainer,
      IndicatorState.error => colorScheme.errorContainer,
    };

    // Respect the user's reduced-motion preference: keep the morphing shape
    // static and swap result states instantly instead of animating.
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

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
          duration: disableAnimations
              ? Duration.zero
              : MotionFallbacks.expressiveFastSpatialDuration,
          switchInCurve: MotionFallbacks.expressiveFastSpatial,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: widget.state == IndicatorState.loading
              ? ShapeRegistry.isReady
                    ? _buildMorphingAnimation(
                        indicatorColor,
                        clampedSize,
                        staticShape: disableAnimations,
                      )
                    : _buildShapePlaceholder(indicatorColor, clampedSize)
              : _buildResultIcon(widget.state, clampedSize),
        ),
      ),
    );
  }

  Widget _buildMorphingAnimation(
    Color indicatorColor,
    double clampedSize, {
    bool staticShape = false,
  }) {
    // With reduced motion, render the current shape once without any
    // rotation or morphing so the indicator stays visually identifiable.
    if (staticShape) {
      return CustomPaint(
        key: const ValueKey(IndicatorState.loading),
        painter: _buildShapePainter(
          indicatorColor,
          clampedSize,
          currentShape: _animationController.currentShape,
          nextShape: _animationController.currentShape,
          progress: 0.0,
          rotation: 0.0,
        ),
      );
    }

    return AnimatedBuilder(
      key: const ValueKey(IndicatorState.loading),
      animation: _animationController.animation,
      builder: (context, child) {
        final morphProgress = _springCurve.transform(
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
          painter: _buildShapePainter(
            indicatorColor,
            clampedSize,
            currentShape: _animationController.currentShape,
            nextShape: _animationController.nextShape,
            progress: morphProgress,
            rotation: globalRotation + stepRotation,
          ),
        );
      },
    );
  }

  MorphingShapePainter _buildShapePainter(
    Color indicatorColor,
    double clampedSize, {
    required ShapeType currentShape,
    required ShapeType nextShape,
    required double progress,
    required double rotation,
  }) {
    return MorphingShapePainter(
      color: indicatorColor,
      currentShape: currentShape,
      nextShape: nextShape,
      progress: progress,
      rotation: rotation,
      path: _path,
      points: _points,
      scale: clampedSize / LoadingIndicatorConstants.defaultContainerSize,
    );
  }

  Widget _buildShapePlaceholder(Color indicatorColor, double clampedSize) {
    // While the SVG shape assets are loading, paint a neutral circle sized to
    // match the largest indicator glyph so the first frames are stable.
    final glyphRadius =
        LoadingIndicatorConstants.svgCenter *
        LoadingIndicatorConstants.svgScaleFactor *
        (clampedSize / LoadingIndicatorConstants.defaultContainerSize);
    return CustomPaint(
      key: const ValueKey('shape-placeholder'),
      painter: _ShapePlaceholderPainter(
        color: indicatorColor,
        radius: glyphRadius,
      ),
    );
  }

  Widget _buildResultIcon(IndicatorState state, double clampedSize) {
    final colorScheme = Theme.of(context).colorScheme;
    final (iconData, iconColor) = switch (state) {
      IndicatorState.success => (
        Icons.check_rounded,
        colorScheme.onPrimaryContainer,
      ),
      IndicatorState.error => (
        Icons.close_rounded,
        colorScheme.onErrorContainer,
      ),
      IndicatorState.loading => throw StateError(
        'Cannot build result icon for loading state',
      ),
    };

    return Icon(
      key: ValueKey(state),
      iconData,
      size: clampedSize * 0.5,
      color: iconColor,
    );
  }
}

/// Paints a filled circle used as a placeholder while shape assets load.
class _ShapePlaceholderPainter extends CustomPainter {
  _ShapePlaceholderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      radius,
      Paint()
        ..color = color
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _ShapePlaceholderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
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
          // Row 3: Custom shape sequences
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              MorphingLoadingindicator.medium(
                shapeSequence: [
                  ShapeType.heart,
                  ShapeType.diamond,
                  ShapeType.clover4,
                  ShapeType.flower,
                ],
              ),
              MorphingLoadingindicator.medium(
                shapeSequence: [
                  ShapeType.circle,
                  ShapeType.square,
                  ShapeType.triangle,
                ],
              ),
              MorphingLoadingindicator.medium(
                shapeSequence: [
                  ShapeType.burst,
                  ShapeType.boom,
                  ShapeType.verySunny,
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
