import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widget_previews.dart';
import 'package:path_drawing/path_drawing.dart';

class RZLoadingIndicator extends StatefulWidget {
  final bool contained;

  const RZLoadingIndicator({super.key, this.contained = false});

  @override
  State<RZLoadingIndicator> createState() => _RZLoadingIndicatorState();
}

class _RZLoadingIndicatorState extends State<RZLoadingIndicator>
    with TickerProviderStateMixin {
  // --- Animation Controllers ---
  late AnimationController _morphController;
  late AnimationController _rotationController;

  // --- State ---
  int _currentIndex = 0;

  // Registry of pre-calculated polar shapes
  late final Map<ShapeType, _PolarShape> _shapeRegistry = {
    ShapeType.cookie4: _PolarShape.fromSvgPath(_ShapePaths.cookie4),
    ShapeType.pentagon: _PolarShape.fromSvgPath(_ShapePaths.pentagon),
    ShapeType.sunny: _PolarShape.fromSvgPath(_ShapePaths.sunny),
    ShapeType.puffyDiamond: _PolarShape.fromSvgPath(_ShapePaths.puffyDiamond),
    ShapeType.oval: _PolarShape.fromSvgPath(_ShapePaths.oval),
  };

  // The sequence of shapes to morph through
  static const List<ShapeType> _shapeSequence = [
    ShapeType.pentagon,
    ShapeType.cookie4,
    ShapeType.sunny,
    ShapeType.oval,
    ShapeType.puffyDiamond,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMorphSequence();
  }

  void _initializeAnimations() {
    // 1. Global Rotation: 360 degrees every 4666ms (Linear)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4666),
    )..repeat();

    // 2. Morph Animation: 650ms per shape transition
    // Uses physics simulation for spring effect
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  void _startMorphSequence() {
    _morphController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _shapeSequence.length;
        });
        _startMorphSequence();
      }
    });
  }

  @override
  void dispose() {
    _morphController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double containerSize = 48.0;

    final Color indicatorColor = widget.contained
        ? colorScheme.onPrimaryContainer
        : colorScheme.primary;
    final Color containerColor = widget.contained
        ? colorScheme.primaryContainer
        : Colors.transparent;

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(color: containerColor, shape: BoxShape.circle),
      child: AnimatedBuilder(
        animation: Listenable.merge([_morphController, _rotationController]),
        builder: (context, child) {
          final double morphProgress = _SpringCurve().transform(
            _morphController.value,
          );

          // Calculate Rotations
          final double globalRotation = _rotationController.value * 2 * math.pi;
          final double currentStepRotation = _currentIndex * (math.pi / 2);
          final double nextStepRotation = (_currentIndex + 1) * (math.pi / 2);

          // Interpolate step rotation using the spring curve
          final double stepRotation = lerpDouble(
            currentStepRotation,
            nextStepRotation,
            morphProgress,
          )!;

          return CustomPaint(
            painter: _MorphingShapePainter(
              color: indicatorColor,
              currentShape: _shapeRegistry[_shapeSequence[_currentIndex]]!,
              nextShape:
                  _shapeRegistry[_shapeSequence[(_currentIndex + 1) %
                      _shapeSequence.length]]!,
              progress: morphProgress,
              rotation: globalRotation + stepRotation,
            ),
          );
        },
      ),
    );
  }
}

class _MorphingShapePainter extends CustomPainter {
  final Color color;
  final _PolarShape currentShape;
  final _PolarShape nextShape;
  final double progress;
  final double rotation;

  const _MorphingShapePainter({
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

    final Path path = Path();
    const int steps = 120; // Resolution of the shape
    final List<Offset> points = [];

    for (int i = 0; i <= steps; i++) {
      final double theta = (i / steps) * 2 * math.pi;

      final double r1 = currentShape.getRadius(theta);
      final double r2 = nextShape.getRadius(theta);

      // Interpolate radius
      final double r = lerpDouble(r1, r2, progress)!;

      final double x = r * math.cos(theta);
      final double y = r * math.sin(theta);
      points.add(Offset(x, y));
    }

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
  bool shouldRepaint(_MorphingShapePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.currentShape != currentShape ||
        oldDelegate.nextShape != nextShape;
  }
}

/// Represents a shape as a polar function r(theta) for easy morphing.
class _PolarShape {
  // Radius values at 1-degree intervals (0 to 359)
  final List<double> radii;

  const _PolarShape(this.radii);

  /// Creates a PolarShape from an SVG path string.
  ///
  /// The SVG path is assumed to be within a specific coordinate space
  /// which is then transformed to the local polar coordinate system.
  factory _PolarShape.fromSvgPath(String svgPathData) {
    return _PolarShape.fromPath(parseSvgPathData(svgPathData));
  }

  factory _PolarShape.fromPath(Path path) {
    final List<double> radii = List.filled(360, 0.0);
    final PathMetrics metrics = path.computeMetrics();

    // robustly check for metrics
    final Iterator<PathMetric> iterator = metrics.iterator;
    if (!iterator.moveNext()) {
      return _PolarShape(radii);
    }

    final PathMetric metric = iterator.current;
    final double length = metric.length;

    // Sample the path to populate the radii table
    const int sampleCount = 1440; // 4 samples per degree

    for (int i = 0; i < sampleCount; i++) {
      final double distance = (i / sampleCount) * length;
      final Tangent? tangent = metric.getTangentForOffset(distance);
      if (tangent != null) {
        // Transform coordinates: SVG (0..380) -> Local (-19..19)
        // Center is assumed to be at 190.0, 190.0 in SVG space
        final double x = (tangent.position.dx - 190.0) * 0.1;
        final double y = (tangent.position.dy - 190.0) * 0.1;

        final double r = math.sqrt(x * x + y * y);
        double theta = math.atan2(y, x);

        if (theta < 0) theta += 2 * math.pi;

        int index = (theta / (2 * math.pi) * 360).round() % 360;

        // Keep the outermost radius for a given angle
        if (r > radii[index]) {
          radii[index] = r;
        }
      }
    }

    _fillGaps(radii);

    return _PolarShape(radii);
  }

  /// Fills zero-radius gaps in the radii array by interpolation or default value.
  static void _fillGaps(List<double> radii) {
    for (int i = 0; i < 360; i++) {
      if (radii[i] == 0.0) {
        int prev = i;
        while (radii[prev] == 0.0) {
          prev = (prev - 1 + 360) % 360;
          if (prev == i) break; // All zeros
        }
        int next = i;
        while (radii[next] == 0.0) {
          next = (next + 1) % 360;
        }

        if (radii[prev] != 0 && radii[next] != 0) {
          radii[i] = (radii[prev] + radii[next]) / 2;
        } else {
          radii[i] = 19.0; // Default fallback radius
        }
      }
    }
  }

  double getRadius(double theta) {
    // Normalize theta to 0..2pi
    theta = theta % (2 * math.pi);
    if (theta < 0) theta += 2 * math.pi;

    final double pos = theta / (2 * math.pi) * 360;
    final int index1 = pos.floor() % 360;
    final int index2 = (index1 + 1) % 360;
    final double t = pos - pos.floor();

    // Linear interpolation between sampled degrees
    return radii[index1] * (1 - t) + radii[index2] * t;
  }
}

class _SpringCurve extends Curve {
  @override
  double transformInternal(double t) {
    final simulation = SpringSimulation(
      const SpringDescription(mass: 1, stiffness: 200, damping: 15),
      0, // start
      1, // end
      0, // velocity
    );
    // Maps time t (0..1) to the simulation time (0..0.650s)
    // The '+ t * (1 - ...)' term ensures it ends exactly at 1.0
    return simulation.x(t * 0.650) + t * (1 - simulation.x(0.650));
  }
}

enum ShapeType { pentagon, cookie4, sunny, oval, puffyDiamond }

class _ShapePaths {
  static const String cookie4 =
      "M230.389 50.473C293.109 23.2328 356.767 86.8908 329.527 149.611L325.023 159.981C316.707 179.13 316.707 200.87 325.023 220.019L329.527 230.389C356.767 293.109 293.109 356.767 230.389 329.527L220.019 325.023C200.87 316.707 179.13 316.707 159.981 325.023L149.611 329.527C86.8908 356.767 23.2328 293.109 50.473 230.389L54.9768 220.019C63.2934 200.87 63.2934 179.13 54.9768 159.981L50.473 149.611C23.2328 86.8908 86.8908 23.2328 149.611 50.473L159.981 54.9768C179.13 63.2934 200.87 63.2934 220.019 54.9768L230.389 50.473Z";

  static const String pentagon =
      "M155.064 49.459C176.093 34.1803 204.569 34.1803 225.598 49.459L322.926 120.171C343.955 135.45 352.754 162.532 344.722 187.253L307.546 301.668C299.514 326.39 276.476 343.127 250.483 343.127H130.18C104.186 343.127 81.1489 326.39 73.1164 301.668L35.9407 187.253C27.9082 162.532 36.7077 135.45 57.737 120.171L155.064 49.459Z";

  static const String sunny =
      "M276.453 68.8118C286.405 69.4881 291.381 69.8263 295.404 71.5853C301.223 74.1305 305.87 78.7766 308.415 84.5965C310.174 88.6186 310.512 93.5948 311.188 103.547L312.732 126.259C313.005 130.284 313.142 132.296 313.579 134.219C314.212 136.997 315.31 139.648 316.827 142.059C317.877 143.728 319.203 145.248 321.856 148.288L336.824 165.438C343.384 172.954 346.663 176.712 348.263 180.8C350.579 186.715 350.579 193.285 348.263 199.2C346.663 203.288 343.384 207.046 336.824 214.562L321.856 231.712C319.203 234.752 317.877 236.272 316.827 237.941C315.31 240.352 314.212 243.003 313.579 245.781C313.142 247.704 313.005 249.716 312.732 253.741L311.188 276.453C310.512 286.405 310.174 291.381 308.415 295.404C305.87 301.223 301.223 305.87 295.404 308.415C291.381 310.174 286.405 310.512 276.453 311.188L253.741 312.732C249.716 313.005 247.704 313.142 245.781 313.579C243.003 314.212 240.352 315.31 237.941 316.827C236.272 317.877 234.752 319.203 231.712 321.856L214.562 336.824C207.046 343.384 203.288 346.663 199.2 348.263C193.285 350.579 186.715 350.579 180.8 348.263C176.712 346.663 172.954 343.384 165.438 336.824L148.288 321.856C145.248 319.203 143.728 317.877 142.059 316.827C139.648 315.31 136.997 314.212 134.219 313.579C132.296 313.142 130.284 313.005 126.259 312.732L103.547 311.188C93.5947 310.512 88.6186 310.174 84.5965 308.415C78.7766 305.87 74.1305 301.223 71.5853 295.404C69.8263 291.381 69.4881 286.405 68.8118 276.453L67.2684 253.741C66.9949 249.716 66.8581 247.704 66.4206 245.781C65.7883 243.003 64.6903 240.352 63.173 237.941C62.123 236.272 60.7965 234.752 58.1437 231.712L43.1756 214.562C36.6164 207.046 33.3369 203.288 31.7366 199.2C29.4211 193.285 29.4211 186.715 31.7366 180.8C33.3369 176.712 36.6164 172.954 43.1756 165.438L58.1437 148.288C60.7965 145.248 62.123 143.728 63.173 142.059C64.6903 139.648 65.7883 136.997 66.4206 134.219C66.8581 132.296 66.9949 130.284 67.2684 126.259L68.8118 103.547C69.4881 93.5948 69.8263 88.6186 71.5853 84.5965C74.1305 78.7766 78.7766 74.1305 84.5965 71.5853C88.6186 69.8263 93.5948 69.4881 103.547 68.8118L126.259 67.2684C130.284 66.9949 132.296 66.8581 134.219 66.4206C136.997 65.7883 139.648 64.6903 142.059 63.173C143.728 62.123 145.248 60.7965 148.288 58.1437L165.438 43.1756C172.954 36.6164 176.712 33.3369 180.8 31.7366C186.715 29.4211 193.285 29.4211 199.2 31.7366C203.288 33.3369 207.046 36.6164 214.562 43.1756L231.712 58.1437C234.752 60.7965 236.272 62.123 237.941 63.173C240.352 64.6903 243.003 65.7883 245.781 66.4206C247.704 66.8581 249.716 66.9949 253.741 67.2684L276.453 68.8118Z";

  static const String puffyDiamond =
      "M279.397 279.754C291.485 267.666 295.573 250.608 291.663 235.157C307.124 239.086 324.202 235.001 336.3 222.902C354.567 204.636 354.567 175.02 336.3 156.754C324.273 144.727 307.325 140.619 291.936 144.43C295.368 129.286 291.188 112.766 279.397 100.975C267.282 88.8601 250.174 84.7804 234.696 88.736C238.798 73.1705 234.747 55.9026 222.544 43.6997C204.278 25.4334 174.662 25.4334 156.396 43.6997C144.266 55.83 140.191 72.9655 144.172 88.4584C129.001 84.9862 112.435 89.1585 100.618 100.975C88.8257 112.767 84.6462 129.289 88.0792 144.434C72.6865 140.616 55.7312 144.723 43.6997 156.754C25.4334 175.02 25.4334 204.636 43.6997 222.902C55.8026 235.005 72.8879 239.089 88.3531 235.153C84.4405 250.605 88.5288 267.665 100.618 279.754C112.385 291.521 128.862 295.708 143.98 292.314C140.328 307.602 144.467 324.371 156.396 336.3C174.662 354.567 204.278 354.567 222.544 336.3C234.544 324.301 238.661 307.403 234.894 292.043C250.32 295.914 267.333 291.817 279.397 279.754Z";

  static const String oval =
      "M271.309 271.309C201.705 340.913 108.877 360.935 63.9707 316.029C19.0648 271.123 39.0867 178.295 108.691 108.691C178.295 39.0867 271.123 19.0648 316.029 63.9707C360.935 108.877 340.913 201.705 271.309 271.309Z";
}

@Preview(name: 'Expressive Loader (Uncontained)')
Widget previewExpressiveLoaderUncontained() =>
    const RZLoadingIndicator(contained: false);

@Preview(name: 'Expressive Loader (Contained)')
Widget previewExpressiveLoaderContained() =>
    const RZLoadingIndicator(contained: true);
