import 'dart:math' as math;
import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';

/// Represents a shape as a polar function r(theta) for easy morphing.
///
/// This class stores radius values at 1-degree intervals (0 to 359 degrees)
/// and provides interpolation for arbitrary angles. This representation
/// enables smooth morphing between different shapes by interpolating
/// corresponding radii at each angle.
///
/// The polar coordinate system used:
/// - Angle theta is measured counter-clockwise from the positive x-axis
/// - Radius r is the distance from the center
/// - Full circle: theta ranges from 0 to 2*pi radians (0 to 360 degrees)
class PolarShape {
  /// Creates a PolarShape with the given radius values.
  ///
  /// The [radii] list must contain exactly 360 values, one for each degree.
  const PolarShape(this.radii);

  /// Creates a PolarShape from an SVG path string.
  ///
  /// The SVG is assumed to be defined in a 380x380 viewport with the center
  /// at (190, 190). The shape is scaled to match the target radius of 19.0
  /// (the active indicator radius in the loading indicator).
  ///
  /// This factory method parses the SVG path data, samples points along the
  /// path, converts them to polar coordinates, and builds a radii lookup table.
  factory PolarShape.fromSvgPath(String svgPathData) {
    return PolarShape.fromPath(parseSvgPathData(svgPathData));
  }

  /// Creates a PolarShape from a Flutter [Path] object.
  ///
  /// The path is assumed to be defined in a 380x380 coordinate space with
  /// the center at (190, 190). The shape is scaled by 0.1 to fit the target
  /// radius of 19.0.
  ///
  /// The algorithm:
  /// 1. Sample 1440 points along the path (4 samples per degree)
  /// 2. Convert each point from Cartesian to polar coordinates
  /// 3. Store the maximum radius found for each 1-degree interval
  /// 4. Fill any gaps using linear interpolation from neighbors
  factory PolarShape.fromPath(Path path) {
    final radii = List<double>.filled(360, 0);
    final metrics = path.computeMetrics();

    final iterator = metrics.iterator;
    if (!iterator.moveNext()) {
      return PolarShape(radii);
    }

    final metric = iterator.current;
    final length = metric.length;

    // Sample the path to populate the radii table
    // Using 1440 samples (4 per degree) for high accuracy
    const sampleCount = 1440;

    for (var i = 0; i < sampleCount; i++) {
      final distance = (i / sampleCount) * length;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        // Transform coordinates: SVG (0..380) -> Local (-19..19)
        // Center is assumed to be at 190.0, 190.0 in SVG space
        // Scale factor: 19.0 / 190.0 = 0.1
        final x = (tangent.position.dx - 190.0) * 0.1;
        final y = (tangent.position.dy - 190.0) * 0.1;

        final r = math.sqrt(x * x + y * y);
        var theta = math.atan2(y, x);

        // Normalize theta to [0, 2*pi)
        if (theta < 0) theta += 2 * math.pi;

        final index = (theta / (2 * math.pi) * 360).round() % 360;

        // Store the maximum radius found for this angle
        // This handles concave shapes correctly by taking the outer boundary
        if (r > radii[index]) {
          radii[index] = r;
        }
      }
    }

    _fillGaps(radii);

    return PolarShape(radii);
  }

  /// Radius values at 1-degree intervals (0 to 359).
  ///
  /// Index 0 corresponds to theta = 0 degrees (positive x-axis direction),
  /// index 90 corresponds to theta = 90 degrees (positive y-axis direction), etc.
  final List<double> radii;

  /// Fills gaps (zero values) in the radii array using linear interpolation.
  ///
  /// This handles cases where the path sampling didn't produce a point
  /// for every degree. Gaps are filled by averaging the nearest non-zero
  /// neighbors on each side.
  static void _fillGaps(List<double> radii) {
    for (var i = 0; i < 360; i++) {
      if (radii[i] == 0.0) {
        // Find previous non-zero radius
        var prev = i;
        while (radii[prev] == 0.0) {
          prev = (prev - 1 + 360) % 360;
          if (prev == i) break; // All zeros - prevent infinite loop
        }

        // Find next non-zero radius
        var next = i;
        while (radii[next] == 0.0) {
          next = (next + 1) % 360;
        }

        // Interpolate or use default radius
        if (radii[prev] != 0 && radii[next] != 0) {
          radii[i] = (radii[prev] + radii[next]) / 2;
        } else {
          // Fallback to default indicator radius
          radii[i] = 19.0;
        }
      }
    }
  }

  /// Gets the interpolated radius at a given angle [theta] (in radians).
  ///
  /// Uses linear interpolation between the two nearest stored radius values
  /// for smooth results at arbitrary angles.
  ///
  /// The angle is automatically normalized to the range [0, 2*pi).
  ///
  /// The [scale] parameter allows resizing the shape. Defaults to 1.0.
  double getRadius(double theta, {double scale = 1.0}) {
    // Normalize angle to [0, 2*pi)
    theta = theta % (2 * math.pi);
    if (theta < 0) theta += 2 * math.pi;

    // Convert angle to position in the radii array
    final pos = theta / (2 * math.pi) * 360;
    final index1 = pos.floor() % 360;
    final index2 = (index1 + 1) % 360;
    final t = pos - pos.floor();

    // Linear interpolation between adjacent radius values
    final rawRadius = radii[index1] * (1 - t) + radii[index2] * t;

    return rawRadius * scale;
  }
}
