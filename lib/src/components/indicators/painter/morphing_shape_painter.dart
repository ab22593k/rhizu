import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../shapes/shape_registry.dart';
import '../shapes/shape_type.dart';

/// A custom painter that renders a morphing shape animation.
///
/// This painter interpolates between two shapes at a given progress value,
/// creating a smooth morphing effect. The shapes are rendered using
/// polar coordinate interpolation to ensure topology-safe morphing
/// (no glitches between shapes with different point counts).
class MorphingShapePainter extends CustomPainter {
  /// The color to fill the shape with.
  final Color color;

  /// The current shape being rendered (starting shape).
  final ShapeType currentShape;

  /// The target shape to morph towards (ending shape).
  final ShapeType nextShape;

  /// The morphing progress from 0.0 (currentShape) to 1.0 (nextShape).
  final double progress;

  /// The total rotation angle in radians.
  ///
  /// This includes both the continuous global rotation and the
  /// step rotation that advances 90 degrees per shape transition.
  final double rotation;

  /// Creates a morphing shape painter.
  ///
  /// All parameters are required and define how the shape should be rendered.
  MorphingShapePainter({
    required this.color,
    required this.currentShape,
    required this.nextShape,
    required this.progress,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotation);

    // Generate a path by interpolating polar coordinates (radius at angle theta)
    // This ensures topology-safe morphing (no glitches between different point counts).
    final Path path = Path();
    final int steps = LoadingIndicatorConstants.shapeResolution;
    final List<Offset> points = [];

    // Get polar shape definitions from registry
    final currentPolarShape = ShapeRegistry.get(currentShape);
    final nextPolarShape = ShapeRegistry.get(nextShape);

    for (int i = 0; i <= steps; i++) {
      final double theta = (i / steps) * 2 * math.pi;

      // Get radius for current and next shape at this angle
      // The rotation is handled by the canvas rotation, not here
      final double r1 = currentPolarShape.getRadius(theta);
      final double r2 = nextPolarShape.getRadius(theta);

      // Interpolate radius based on progress
      final double r = lerpDouble(r1, r2, progress)!;

      // Convert polar to Cartesian coordinates
      final double x = r * math.cos(theta);
      final double y = r * math.sin(theta);
      points.add(Offset(x, y));
    }

    // Build the path from calculated points
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(MorphingShapePainter oldDelegate) {
    // Repaint if any visual property changes
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.currentShape != currentShape ||
        oldDelegate.nextShape != nextShape ||
        oldDelegate.color != color;
  }
}
