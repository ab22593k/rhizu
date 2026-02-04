import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('Shape System Tests', () {
    test('Corner Radius Tokens match spec', () {
      expect(ShapeScale.none, 0.0);
      expect(ShapeScale.extraSmall, 4.0);
      expect(ShapeScale.small, 8.0);
      expect(ShapeScale.medium, 12.0);
      expect(ShapeScale.large, 16.0);
      expect(ShapeScale.largeIncreased, 20.0);
      expect(ShapeScale.extraLarge, 28.0);
      expect(ShapeScale.extraLargeIncreased, 32.0);
      expect(ShapeScale.extraExtraLarge, 48.0);
    });

    test('Expressive Shape Paths are correct', () {
      expect(ExpressiveShapes.arch, 'assets/shapes/material_shape_arch.svg');
      expect(ExpressiveShapes.boom, 'assets/shapes/material_shape_boom.svg');
      expect(
        ExpressiveShapes.flower,
        'assets/shapes/material_shape_flower.svg',
      );
    });
  });
}
