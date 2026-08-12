import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/contracts/indicators/indicator_contract.dart'
    show Containment;
import 'package:rhizu/src/ui/components/indicators/animation/loading_animation_controller.dart';
import 'package:rhizu/src/ui/components/indicators/animation/spring_curve.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/painter/morphing_shape_painter.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_registry.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_type.dart';
import 'package:rhizu/src/ui/styles/motion/fallbacks.dart';

// Canonical definitions live in the contracts; re-exported so the public
// barrel keeps exposing them through this widget file.
export 'package:rhizu/src/contracts/indicators/indicator_contract.dart'
    show Containment;
export 'shapes/shape_type.dart';

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
/// ```
class MorphingLoadingindicator extends StatefulWidget {
  /// Creates a loading indicator.
  ///
  /// The [containment] parameter controls the visual presentation.
  /// The [shapeSequence] parameter controls which [ShapeType]s the indicator
  /// morphs through while loading.
  const MorphingLoadingindicator({
    super.key,
    this.containment = Containment.simple,
    this.size = LoadingIndicatorConstants.defaultContainerSize,
    this.shapeSequence = defaultShapeSequence,
  });

  /// Creates a small loading indicator (24dp).
  const MorphingLoadingindicator.small({
    super.key,
    this.containment = Containment.simple,
    this.shapeSequence = defaultShapeSequence,
  }) : size = LoadingIndicatorConstants.minContainerSize;

  /// Creates a medium loading indicator (48dp).
  const MorphingLoadingindicator.medium({
    super.key,
    this.containment = Containment.simple,
    this.shapeSequence = defaultShapeSequence,
  }) : size = LoadingIndicatorConstants.defaultContainerSize;

  /// Creates a large loading indicator (96dp).
  const MorphingLoadingindicator.large({
    super.key,
    this.containment = Containment.simple,
    this.shapeSequence = defaultShapeSequence,
  }) : size = 96.0;

  /// Creates an extra large loading indicator (144dp).
  const MorphingLoadingindicator.extraLarge({
    super.key,
    this.containment = Containment.simple,
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

    // Respect the user's reduced-motion preference: keep the morphing shape
    // static instead of animating.
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

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
        // Crossfades the placeholder into the morphing shape once the SVG
        // shape assets finish loading.
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
          child: ShapeRegistry.isReady
              ? _buildMorphingAnimation(
                  indicatorColor,
                  clampedSize,
                  staticShape: disableAnimations,
                )
              : _buildShapePlaceholder(indicatorColor, clampedSize),
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
        key: const ValueKey('loading'),
        size: Size.square(clampedSize),
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
      key: const ValueKey('loading'),
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
          size: Size.square(clampedSize),
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
      size: Size.square(clampedSize),
      painter: _ShapePlaceholderPainter(
        color: indicatorColor,
        radius: glyphRadius,
      ),
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
              MorphingLoadingindicator.small(),
              MorphingLoadingindicator.medium(),
              MorphingLoadingindicator.large(),
              MorphingLoadingindicator.extraLarge(),
            ],
          ),
          // Row 2: Contained (different sizes)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24,
            children: [
              MorphingLoadingindicator.small(
                containment: Containment.contained,
              ),
              MorphingLoadingindicator.medium(
                containment: Containment.contained,
              ),
              MorphingLoadingindicator.large(
                containment: Containment.contained,
              ),
              MorphingLoadingindicator.extraLarge(
                containment: Containment.contained,
              ),
            ],
          ),
          // Row 3: Custom shape sequences
          Row(
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
