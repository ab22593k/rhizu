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
  // Animation Controllers
  late AnimationController _morphController;
  late AnimationController _rotationController;

  // State for shape sequence
  int _currentIndex = 0;

  // The sequence of 7 shapes as defined in specs
  final List<ShapeType> _shapeSequence = [
    ShapeType.burst,
    ShapeType.cookie9,
    ShapeType.pentagon,
    ShapeType.pill,
    ShapeType.sunny,
    ShapeType.cookie4,
    ShapeType.oval,
  ];

  @override
  void initState() {
    super.initState();

    // 1. Global Rotation: 360 degrees every 4666ms (Linear)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4666),
    )..repeat();

    // 2. Morph Animation: 650ms per shape transition
    // Using a physics simulation to match the Spring specs:
    // Stiffness: 200, Damping: 0.6
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _startMorphSequence();
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

    // Dimensions according to specs
    const double containerSize = 48.0;

    // Colors
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
          // Custom Spring Curve application
          // We apply the spring curve to the linear 0-1 progress of the morph controller
          final double morphProgress = _SpringCurve().transform(
            _morphController.value,
          );

          // Calculate Rotation:
          // Global Rotation (Linear) + Step Rotation (90deg per completed step)
          // To make it smooth, we interpolate the step rotation based on morph progress
          // Step Rotation: +90deg increment per morph step.
          final double globalRotation = _rotationController.value * 2 * math.pi;

          // Current step rotation base
          final double currentStepRotation = _currentIndex * (math.pi / 2);
          // Next step rotation target
          final double nextStepRotation = (_currentIndex + 1) * (math.pi / 2);

          // Interpolate step rotation using the spring curve for "expressive" feel
          final double stepRotation = lerpDouble(
            currentStepRotation,
            nextStepRotation,
            morphProgress,
          )!;

          return CustomPaint(
            painter: _MorphingShapePainter(
              color: indicatorColor,
              currentShape: _shapeSequence[_currentIndex],
              nextShape:
                  _shapeSequence[(_currentIndex + 1) % _shapeSequence.length],
              progress: morphProgress,
              rotation: globalRotation + stepRotation,
            ),
          );
        },
      ),
    );
  }
}

/// Matches the Spec: Spring, Damping 0.6, Stiffness 200
class _SpringCurve extends Curve {
  @override
  double transformInternal(double t) {
    // A simplified spring simulation mapped to 0.0 - 1.0 time
    // Standard critically damped spring approximation
    final simulation = SpringSimulation(
      const SpringDescription(
        mass: 1,
        stiffness: 200,
        damping: 15,
      ), // Damping ratio 0.6
      0,
      1,
      0,
    );
    // 0.650 seconds duration. Simulation uses seconds.
    return simulation.x(t * 0.650) + t * (1 - simulation.x(0.650));
  }
}

enum ShapeType { burst, cookie9, pentagon, pill, sunny, cookie4, oval }

class _MorphingShapePainter extends CustomPainter {
  final Color color;
  final ShapeType currentShape;
  final ShapeType nextShape;
  final double progress;
  final double rotation;

  _MorphingShapePainter({
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

    // Active Indicator Size is 38dp within a 48dp container.
    // Radius = 38 / 2 = 19.
    const double radius = 19.0;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(rotation);

    // We generate a path by interpolating polar coordinates (radius at angle theta)
    // This ensures topology-safe morphing (no glitches between different point counts).
    final Path path = Path();
    const int steps = 120; // Resolution of the shape
    final List<Offset> points = [];

    for (int i = 0; i <= steps; i++) {
      final double theta = (i / steps) * 2 * math.pi;

      // Get radius for current and next shape at this angle
      final double r1 = _getRadius(theta, currentShape, radius);
      // We do not rotate the theta for the next shape in the polar function
      // because the rotation is handled by the canvas rotation logic + step rotation.
      final double r2 = _getRadius(theta, nextShape, radius);

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

  /// Calculates the radius at a specific angle [theta] for a given [shape].
  /// [baseRadius] is the maximum bounding radius (19.0).
  double _getRadius(double theta, ShapeType shape, double baseRadius) {
    // Normalize angle
    theta = theta % (2 * math.pi);

    switch (shape) {
      case ShapeType.burst:
        return _burstShape.getRadius(theta);

      case ShapeType.cookie9:
        return _cookie9Shape.getRadius(theta);

      case ShapeType.pentagon:
        return _pentagonShape.getRadius(theta);

      case ShapeType.pill:
        return _pillShape.getRadius(theta);

      case ShapeType.sunny:
        return _sunnyShape.getRadius(theta);

      case ShapeType.cookie4:
        return _cookie4Shape.getRadius(theta);

      case ShapeType.oval:
        return _ovalShape.getRadius(theta);
    }
  }

  @override
  bool shouldRepaint(_MorphingShapePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.currentShape != currentShape;
  }
}

final _PolarShape _burstShape = _PolarShape.fromSvgPath(
  "M187.293 26.6421C188.056 25.2785 188.437 24.5966 188.902 24.3108C189.575 23.8964 190.425 23.8964 191.098 24.3108C191.563 24.5966 191.944 25.2785 192.707 26.6421L218.917 73.4925C219.386 74.3306 219.62 74.7497 219.937 75.0046C220.396 75.3737 220.989 75.5326 221.571 75.4425C221.973 75.3802 222.386 75.1345 223.211 74.6431L269.335 47.1743C270.677 46.3748 271.348 45.9751 271.893 45.9598C272.684 45.9377 273.42 46.3624 273.796 47.0581C274.055 47.5379 274.045 48.3191 274.023 49.8814L273.296 103.56C273.283 104.52 273.277 105 273.424 105.38C273.637 105.929 274.071 106.363 274.62 106.576C275 106.723 275.48 106.717 276.44 106.704L330.119 105.977C331.681 105.955 332.462 105.945 332.942 106.204C333.638 106.58 334.062 107.316 334.04 108.107C334.025 108.652 333.625 109.323 332.826 110.665L305.357 156.789C304.865 157.614 304.62 158.027 304.557 158.429C304.467 159.011 304.626 159.604 304.995 160.063C305.25 160.38 305.669 160.614 306.508 161.083L353.358 187.293C354.722 188.056 355.403 188.437 355.689 188.902C356.104 189.575 356.104 190.425 355.689 191.098C355.403 191.563 354.722 191.944 353.358 192.707L306.508 218.917C305.669 219.386 305.25 219.62 304.995 219.937C304.626 220.396 304.467 220.989 304.557 221.571C304.62 221.973 304.865 222.386 305.357 223.211L332.826 269.335C333.625 270.677 334.025 271.348 334.04 271.893C334.062 272.684 333.638 273.42 332.942 273.796C332.462 274.055 331.681 274.045 330.119 274.023L276.44 273.296C275.48 273.283 275 273.277 274.62 273.424C274.071 273.637 273.637 274.071 273.424 274.62C273.277 275 273.283 275.48 273.296 276.44L274.023 330.119C274.045 331.681 274.055 332.462 273.796 332.942C273.42 333.638 272.684 334.062 271.893 334.04C271.348 334.025 270.677 333.625 269.335 332.826L223.211 305.357C222.386 304.865 221.973 304.62 221.571 304.557C220.989 304.467 220.396 304.626 219.937 304.995C219.62 305.25 219.386 305.669 218.917 306.508L192.707 353.358C191.944 354.722 191.563 355.403 191.098 355.689C190.425 356.104 189.575 356.104 188.902 355.689C188.437 355.403 188.056 354.722 187.293 353.358L161.083 306.508C160.614 305.669 160.38 305.25 160.063 304.995C159.604 304.626 159.011 304.467 158.429 304.557C158.027 304.62 157.614 304.865 156.789 305.357L110.665 332.826C109.323 333.625 108.652 334.025 108.107 334.04C107.316 334.062 106.58 333.638 106.204 332.942C105.945 332.462 105.955 331.681 105.977 330.119L106.704 276.44C106.717 275.48 106.723 275 106.576 274.62C106.363 274.071 105.929 273.637 105.38 273.424C105 273.277 104.52 273.283 103.56 273.296L49.8814 274.023C48.3191 274.045 47.5379 274.055 47.0581 273.796C46.3624 273.42 45.9377 272.684 45.9598 271.893C45.9751 271.348 46.3748 270.677 47.1743 269.335L74.6431 223.211C75.1345 222.386 75.3802 221.973 75.4425 221.571C75.5326 220.989 75.3737 220.396 75.0046 219.937C74.7497 219.62 74.3306 219.386 73.4925 218.917L26.6421 192.707C25.2785 191.944 24.5966 191.563 24.3108 191.098C23.8964 190.425 23.8964 189.575 24.3108 188.902C24.5966 188.437 25.2785 188.056 26.6421 187.293L73.4925 161.083C74.3306 160.614 74.7497 160.38 75.0046 160.063C75.3737 159.604 75.5326 159.011 75.4425 158.429C75.3802 158.027 75.1345 157.614 74.6431 156.789L47.1743 110.665C46.3748 109.323 45.9751 108.652 45.9598 108.107C45.9377 107.316 46.3624 106.58 47.0581 106.204C47.5379 105.945 48.3191 105.955 49.8814 105.977L103.56 106.704C104.52 106.717 105 106.723 105.38 106.576C105.929 106.363 106.363 105.929 106.576 105.38C106.723 105 106.717 104.52 106.704 103.56L105.977 49.8814C105.955 48.3191 105.945 47.5379 106.204 47.0581C106.58 46.3624 107.316 45.9377 108.107 45.9598C108.652 45.9751 109.323 46.3748 110.665 47.1743L156.789 74.6431C157.614 75.1345 158.027 75.3802 158.429 75.4425C159.011 75.5326 159.604 75.3737 160.063 75.0046C160.38 74.7497 160.614 74.3306 161.083 73.4925L187.293 26.6421Z",
);

final _PolarShape _cookie4Shape = _PolarShape.fromSvgPath(
  "M230.389 50.473C293.109 23.2328 356.767 86.8908 329.527 149.611L325.023 159.981C316.707 179.13 316.707 200.87 325.023 220.019L329.527 230.389C356.767 293.109 293.109 356.767 230.389 329.527L220.019 325.023C200.87 316.707 179.13 316.707 159.981 325.023L149.611 329.527C86.8908 356.767 23.2328 293.109 50.473 230.389L54.9768 220.019C63.2934 200.87 63.2934 179.13 54.9768 159.981L50.473 149.611C23.2328 86.8908 86.8908 23.2328 149.611 50.473L159.981 54.9768C179.13 63.2934 200.87 63.2934 220.019 54.9768L230.389 50.473Z",
);

final _PolarShape _cookie9Shape = _PolarShape.fromSvgPath(
  "M154.828 43.2757C156.574 41.8498 157.448 41.1369 158.245 40.5351C177.03 26.3549 202.97 26.3549 221.755 40.5351C222.552 41.1369 223.425 41.8498 225.172 43.2757C225.952 43.9121 226.342 44.2304 226.727 44.5333C235.567 51.4788 246.406 55.4148 257.652 55.7636C258.143 55.7788 258.647 55.7851 259.654 55.7976C261.911 55.8255 263.039 55.8395 264.037 55.8898C287.563 57.0742 307.435 73.7107 312.689 96.6205C312.912 97.5929 313.121 98.6991 313.541 100.912C313.728 101.899 313.822 102.393 313.922 102.872C316.219 113.862 321.986 123.828 330.377 131.308C330.743 131.635 331.125 131.963 331.888 132.618C333.599 134.087 334.454 134.821 335.187 135.5C352.445 151.495 356.95 176.983 346.215 197.903C345.76 198.791 345.208 199.773 344.104 201.737C343.611 202.613 343.364 203.052 343.132 203.483C337.812 213.375 335.809 224.708 337.418 235.82C337.488 236.304 337.569 236.8 337.732 237.792C338.096 240.014 338.278 241.125 338.402 242.115C341.318 265.436 328.347 287.851 306.647 296.992C305.726 297.379 304.67 297.778 302.559 298.574C301.617 298.93 301.146 299.107 300.69 299.289C290.241 303.455 281.406 310.852 275.48 320.395C275.221 320.811 274.964 321.243 274.449 322.108C273.297 324.043 272.721 325.011 272.178 325.849C259.387 345.584 235.011 354.436 212.498 347.521C211.543 347.228 210.477 346.856 208.347 346.112C207.396 345.78 206.921 345.614 206.455 345.461C195.767 341.951 184.233 341.951 173.545 345.461C173.079 345.614 172.603 345.78 171.652 346.112C169.522 346.856 168.457 347.228 167.502 347.521C144.989 354.436 120.613 345.584 107.822 325.849C107.279 325.011 106.703 324.043 105.55 322.108C105.036 321.243 104.779 320.811 104.52 320.395C98.5939 310.852 89.7583 303.455 79.3096 299.289C78.8539 299.107 78.3827 298.93 77.4404 298.574C75.3294 297.778 74.274 297.379 73.3529 296.992C51.6523 287.851 38.6819 265.436 41.598 242.115C41.7218 241.125 41.9039 240.014 42.2682 237.792C42.4308 236.8 42.5121 236.304 42.5822 235.82C44.1908 224.708 42.188 213.375 36.8675 203.483C36.6354 203.052 36.389 202.613 35.8962 201.737C34.7921 199.773 34.2401 198.791 33.7845 197.903C23.0499 176.983 27.5544 151.495 44.8128 135.5C45.5454 134.821 46.4007 134.087 48.1113 132.618C48.875 131.963 49.2568 131.635 49.6228 131.308C58.0134 123.828 63.7804 113.862 66.0777 102.872C66.1779 102.393 66.2715 101.899 66.4588 100.912C66.8783 98.6991 67.088 97.5928 67.311 96.6205C72.5652 73.7107 92.4369 57.0742 115.962 55.8898C116.961 55.8395 118.089 55.8255 120.346 55.7976C121.353 55.7851 121.857 55.7788 122.347 55.7636C133.594 55.4148 144.432 51.4788 153.272 44.5333C153.658 44.2304 154.048 43.9121 154.828 43.2757Z",
);

final _PolarShape _pentagonShape = _PolarShape.fromSvgPath(
  "M155.064 49.459C176.093 34.1803 204.569 34.1803 225.598 49.459L322.926 120.171C343.955 135.45 352.754 162.532 344.722 187.253L307.546 301.668C299.514 326.39 276.476 343.127 250.483 343.127H130.18C104.186 343.127 81.1489 326.39 73.1164 301.668L35.9407 187.253C27.9082 162.532 36.7077 135.45 57.737 120.171L155.064 49.459Z",
);

final _PolarShape _sunnyShape = _PolarShape.fromSvgPath(
  "M276.453 68.8118C286.405 69.4881 291.381 69.8263 295.404 71.5853C301.223 74.1305 305.87 78.7766 308.415 84.5965C310.174 88.6186 310.512 93.5948 311.188 103.547L312.732 126.259C313.005 130.284 313.142 132.296 313.579 134.219C314.212 136.997 315.31 139.648 316.827 142.059C317.877 143.728 319.203 145.248 321.856 148.288L336.824 165.438C343.384 172.954 346.663 176.712 348.263 180.8C350.579 186.715 350.579 193.285 348.263 199.2C346.663 203.288 343.384 207.046 336.824 214.562L321.856 231.712C319.203 234.752 317.877 236.272 316.827 237.941C315.31 240.352 314.212 243.003 313.579 245.781C313.142 247.704 313.005 249.716 312.732 253.741L311.188 276.453C310.512 286.405 310.174 291.381 308.415 295.404C305.87 301.223 301.223 305.87 295.404 308.415C291.381 310.174 286.405 310.512 276.453 311.188L253.741 312.732C249.716 313.005 247.704 313.142 245.781 313.579C243.003 314.212 240.352 315.31 237.941 316.827C236.272 317.877 234.752 319.203 231.712 321.856L214.562 336.824C207.046 343.384 203.288 346.663 199.2 348.263C193.285 350.579 186.715 350.579 180.8 348.263C176.712 346.663 172.954 343.384 165.438 336.824L148.288 321.856C145.248 319.203 143.728 317.877 142.059 316.827C139.648 315.31 136.997 314.212 134.219 313.579C132.296 313.142 130.284 313.005 126.259 312.732L103.547 311.188C93.5947 310.512 88.6186 310.174 84.5965 308.415C78.7766 305.87 74.1305 301.223 71.5853 295.404C69.8263 291.381 69.4881 286.405 68.8118 276.453L67.2684 253.741C66.9949 249.716 66.8581 247.704 66.4206 245.781C65.7883 243.003 64.6903 240.352 63.173 237.941C62.123 236.272 60.7965 234.752 58.1437 231.712L43.1756 214.562C36.6164 207.046 33.3369 203.288 31.7366 199.2C29.4211 193.285 29.4211 186.715 31.7366 180.8C33.3369 176.712 36.6164 172.954 43.1756 165.438L58.1437 148.288C60.7965 145.248 62.123 143.728 63.173 142.059C64.6903 139.648 65.7883 136.997 66.4206 134.219C66.8581 132.296 66.9949 130.284 67.2684 126.259L68.8118 103.547C69.4881 93.5948 69.8263 88.6186 71.5853 84.5965C74.1305 78.7766 78.7766 74.1305 84.5965 71.5853C88.6186 69.8263 93.5948 69.4881 103.547 68.8118L126.259 67.2684C130.284 66.9949 132.296 66.8581 134.219 66.4206C136.997 65.7883 139.648 64.6903 142.059 63.173C143.728 62.123 145.248 60.7966 148.288 58.1437L165.438 43.1756C172.954 36.6164 176.712 33.3369 180.8 31.7366C186.715 29.4211 193.285 29.4211 199.2 31.7366C203.288 33.3369 207.046 36.6164 214.562 43.1756L231.712 58.1437C234.752 60.7966 236.272 62.123 237.941 63.173C240.352 64.6903 243.003 65.7883 245.781 66.4206C247.704 66.8581 249.716 66.9949 253.741 67.2684L276.453 68.8118Z",
);

final _PolarShape _pillShape = _PolarShape.fromSvgPath(
  "M116.116 71.7851C169.162 18.7383 255.168 18.7383 308.215 71.7851C361.262 124.832 361.262 210.838 308.215 263.884L263.884 308.215C210.838 361.262 124.832 361.262 71.7851 308.215C18.7383 255.168 18.7383 169.162 71.7851 116.116L116.116 71.7851Z",
);

final _PolarShape _ovalShape = _PolarShape.fromSvgPath(
  "M271.309 271.309C201.705 340.913 108.877 360.935 63.9707 316.029C19.0648 271.123 39.0867 178.295 108.691 108.691C178.295 39.0867 271.123 19.0648 316.029 63.9707C360.935 108.877 340.913 201.705 271.309 271.309Z",
);

/// Represents a shape as a polar function r(theta) for easy morphing.
class _PolarShape {
  // Radius values at 1-degree intervals (0 to 359)
  final List<double> radii;

  const _PolarShape(this.radii);

  /// Creates a PolarShape from an SVG path string.
  /// Assumes the SVG is defined in a 380x380 viewport (center at 190, 190).
  /// Scales the shape to match the target radius of 19.0.
  factory _PolarShape.fromSvgPath(String svgPathData) {
    return _PolarShape.fromPath(parseSvgPathData(svgPathData));
  }

  factory _PolarShape.fromPath(Path path) {
    final List<double> radii = List.filled(360, 0.0);
    final PathMetrics metrics = path.computeMetrics();

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
        // Scale factor: 19.0 / 190.0 = 0.1
        final double x = (tangent.position.dx - 190.0) * 0.1;
        final double y = (tangent.position.dy - 190.0) * 0.1;

        final double r = math.sqrt(x * x + y * y);
        double theta = math.atan2(y, x);

        if (theta < 0) theta += 2 * math.pi;

        int index = (theta / (2 * math.pi) * 360).round() % 360;

        // Store the maximum radius found for this angle
        if (r > radii[index]) {
          radii[index] = r;
        }
      }
    }

    _fillGaps(radii);

    return _PolarShape(radii);
  }

  static void _fillGaps(List<double> radii) {
    for (int i = 0; i < 360; i++) {
      if (radii[i] == 0.0) {
        int prev = i;
        while (radii[prev] == 0.0) {
          prev = (prev - 1 + 360) % 360;
          if (prev == i) break;
        }
        int next = i;
        while (radii[next] == 0.0) {
          next = (next + 1) % 360;
        }

        if (radii[prev] != 0 && radii[next] != 0) {
          radii[i] = (radii[prev] + radii[next]) / 2;
        } else {
          radii[i] = 19.0;
        }
      }
    }
  }

  double getRadius(double theta) {
    theta = theta % (2 * math.pi);
    if (theta < 0) theta += 2 * math.pi;

    final double pos = theta / (2 * math.pi) * 360;
    final int index1 = pos.floor() % 360;
    final int index2 = (index1 + 1) % 360;
    final double t = pos - pos.floor();

    return radii[index1] * (1 - t) + radii[index2] * t;
  }
}

@Preview(name: 'Expressive Loader (Contained)')
Widget previewExpressiveLoaderContained() => const MaterialApp(
  home: Scaffold(
    body: Center(
      child: Row(
        mainAxisAlignment: .center,
        spacing: 40.0,
        children: [
          RZLoadingIndicator(contained: false),
          RZLoadingIndicator(contained: true),
        ],
      ),
    ),
  ),
);
