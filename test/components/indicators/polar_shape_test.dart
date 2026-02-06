import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/indicators/shapes/polar_shape.dart';
import 'package:rhizu/src/components/indicators/shapes/shape_type.dart';
import 'package:rhizu/src/components/indicators/shapes/shape_registry.dart';

void main() {
  group('ShapeType', () {
    test('has 7 defined shape types', () {
      expect(ShapeType.values.length, equals(7));
    });

    test('default shape sequence has correct order', () {
      expect(defaultShapeSequence.length, equals(7));
      expect(defaultShapeSequence[0], equals(ShapeType.burst));
      expect(defaultShapeSequence[1], equals(ShapeType.cookie9));
      expect(defaultShapeSequence[2], equals(ShapeType.pentagon));
      expect(defaultShapeSequence[3], equals(ShapeType.pill));
      expect(defaultShapeSequence[4], equals(ShapeType.sunny));
      expect(defaultShapeSequence[5], equals(ShapeType.cookie4));
      expect(defaultShapeSequence[6], equals(ShapeType.oval));
    });
  });

  group('PolarShape', () {
    test('create from SVG path generates radii array', () {
      // Create a simple circle-like SVG path
      const svgPath =
          'M 200, 200 m -75, 0 a 75,75 0 1,0 150,0 a 75,75 0 1,0 -150,0';
      final shape = PolarShape.fromSvgPath(svgPath);

      expect(shape.radii.length, equals(360));
      // All radii should be non-zero for a filled circle
      expect(shape.radii.every((r) => r > 0), isTrue);
    });

    test('getRadius returns interpolated value', () {
      // Create a shape with uniform radius
      final radii = List<double>.filled(360, 10.0);
      final shape = PolarShape(radii);

      // Test various angles
      expect(shape.getRadius(0), equals(10.0));
      expect(shape.getRadius(math.pi / 2), equals(10.0));
      expect(shape.getRadius(math.pi), equals(10.0));
      expect(shape.getRadius(3 * math.pi / 2), equals(10.0));
    });

    test('getRadius handles angle normalization', () {
      final radii = List<double>.filled(360, 5.0);
      final shape = PolarShape(radii);

      // Negative angles should be normalized
      expect(shape.getRadius(-math.pi), equals(5.0));

      // Angles > 2*pi should be normalized
      expect(shape.getRadius(4 * math.pi), equals(5.0));
    });

    test('getRadius interpolates between adjacent values', () {
      // Create radii where even indices are 10.0 and odd are 20.0
      final radii = List<double>.generate(360, (i) => i.isEven ? 10.0 : 20.0);
      final shape = PolarShape(radii);

      // At angle 0 (index 0), should be 10.0
      expect(shape.getRadius(0), closeTo(10.0, 0.1));

      // At angle corresponding to index 1 (1 degree), should be 20.0
      final angle1Degree = 2 * math.pi / 360;
      expect(shape.getRadius(angle1Degree), closeTo(20.0, 0.1));
    });
  });

  group('ShapeRegistry', () {
    test('all shape types can be retrieved', () {
      for (final type in ShapeType.values) {
        final shape = ShapeRegistry.get(type);
        expect(shape, isA<PolarShape>());
        expect(shape.radii.length, equals(360));
        // All shapes should have non-zero radii
        expect(shape.radii.any((r) => r > 0), isTrue);
      }
    });

    test('shape registry caches shapes', () {
      final shape1 = ShapeRegistry.get(ShapeType.burst);
      final shape2 = ShapeRegistry.get(ShapeType.burst);

      // Should be the same instance (cached)
      expect(identical(shape1, shape2), isTrue);
    });

    test('different shape types produce different radii', () {
      final burstShape = ShapeRegistry.get(ShapeType.burst);
      final ovalShape = ShapeRegistry.get(ShapeType.oval);

      // Burst and oval should have significantly different radii
      final burstAvg = burstShape.radii.reduce((a, b) => a + b) / 360;
      final ovalAvg = ovalShape.radii.reduce((a, b) => a + b) / 360;

      // Average radii should be different (they're different shapes)
      expect((burstAvg - ovalAvg).abs() > 0.1, isTrue);
    });
  });
}
