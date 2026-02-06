import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('ShapeTokens', () {
    test('Corner radius tokens match Material 3 spec', () {
      expect(ShapeTokens.cornerNone, 0.0);
      expect(ShapeTokens.cornerExtraSmall, 4.0);
      expect(ShapeTokens.cornerSmall, 8.0);
      expect(ShapeTokens.cornerMedium, 12.0);
      expect(ShapeTokens.cornerLarge, 16.0);
      expect(ShapeTokens.cornerLargeIncreased, 20.0);
      expect(ShapeTokens.cornerExtraLarge, 28.0);
      expect(ShapeTokens.cornerExtraLargeIncreased, 32.0);
      expect(ShapeTokens.cornerExtraExtraLarge, 48.0);
      expect(ShapeTokens.cornerFull, double.infinity);
    });

    test('BorderRadius tokens are correctly derived', () {
      expect(ShapeTokens.borderRadiusNone, BorderRadius.zero);
      expect(ShapeTokens.borderRadiusExtraSmall, BorderRadius.circular(4));
      expect(ShapeTokens.borderRadiusSmall, BorderRadius.circular(8));
      expect(ShapeTokens.borderRadiusMedium, BorderRadius.circular(12));
      expect(ShapeTokens.borderRadiusLarge, BorderRadius.circular(16));
      expect(
        ShapeTokens.borderRadiusLargeIncreased,
        BorderRadius.circular(20),
      );
      expect(ShapeTokens.borderRadiusExtraLarge, BorderRadius.circular(28));
      expect(
        ShapeTokens.borderRadiusExtraLargeIncreased,
        BorderRadius.circular(32),
      );
      expect(
        ShapeTokens.borderRadiusExtraExtraLarge,
        BorderRadius.circular(48),
      );
      expect(
        ShapeTokens.borderRadiusFull,
        BorderRadius.circular(double.infinity),
      );
    });

    test('calculateOpticalRoundness returns correct inner radius', () {
      expect(ShapeTokens.calculateOpticalRoundness(48, 14), 34.0);
      expect(ShapeTokens.calculateOpticalRoundness(16, 4), 12.0);
      expect(
        ShapeTokens.calculateOpticalRoundness(8, 10),
        0.0,
      ); // Should not be negative
    });
  });

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
