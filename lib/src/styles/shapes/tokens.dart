import 'package:flutter/widgets.dart';

/// Material 3 Shape System Tokens.
///
/// These tokens follow the Design System Package (DSP) naming convention
/// and provide both raw corner radii and derived [BorderRadius] objects.
class ShapeTokens {
  const ShapeTokens._();

  /// Corner radius: None (0.0dp)
  static const double cornerNone = 0;

  /// Corner radius: Extra small (4.0dp)
  static const double cornerExtraSmall = 4;

  /// Corner radius: Small (8.0dp)
  static const double cornerSmall = 8;

  /// Corner radius: Medium (12.0dp)
  static const double cornerMedium = 12;

  /// Corner radius: Large (16.0dp)
  static const double cornerLarge = 16;

  /// Corner radius: Large increased (20.0dp)
  static const double cornerLargeIncreased = 20;

  /// Corner radius: Extra large (28.0dp)
  static const double cornerExtraLarge = 28;

  /// Corner radius: Extra large increased (32.0dp)
  static const double cornerExtraLargeIncreased = 32;

  /// Corner radius: Extra extra large (48.0dp)
  static const double cornerExtraExtraLarge = 48;

  /// Corner radius: Full (fully rounded)
  static const double cornerFull = double.infinity;

  /// Border radius: None (0.0dp)
  static const BorderRadius borderRadiusNone = BorderRadius.zero;

  /// Border radius: Extra small (4.0dp)
  static const BorderRadius borderRadiusExtraSmall = BorderRadius.all(
    Radius.circular(cornerExtraSmall),
  );

  /// Border radius: Small (8.0dp)
  static const BorderRadius borderRadiusSmall = BorderRadius.all(
    Radius.circular(cornerSmall),
  );

  /// Border radius: Medium (12.0dp)
  static const BorderRadius borderRadiusMedium = BorderRadius.all(
    Radius.circular(cornerMedium),
  );

  /// Border radius: Large (16.0dp)
  static const BorderRadius borderRadiusLarge = BorderRadius.all(
    Radius.circular(cornerLarge),
  );

  /// Border radius: Large increased (20.0dp)
  static const BorderRadius borderRadiusLargeIncreased = BorderRadius.all(
    Radius.circular(cornerLargeIncreased),
  );

  /// Border radius: Extra large (28.0dp)
  static const BorderRadius borderRadiusExtraLarge = BorderRadius.all(
    Radius.circular(cornerExtraLarge),
  );

  /// Border radius: Extra large increased (32.0dp)
  static const BorderRadius borderRadiusExtraLargeIncreased = BorderRadius.all(
    Radius.circular(cornerExtraLargeIncreased),
  );

  /// Border radius: Extra extra large (48.0dp)
  static const BorderRadius borderRadiusExtraExtraLarge = BorderRadius.all(
    Radius.circular(cornerExtraExtraLarge),
  );

  /// Border radius: Full (fully rounded)
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(cornerFull),
  );

  /// Calculates the inner radius for nested containers to maintain optical roundness.
  ///
  /// Formula: `Outer Radius - Padding = Inner Radius`
  ///
  /// Returns 0.0 if the result is negative.
  static double calculateOpticalRoundness(double outerRadius, double padding) {
    final result = outerRadius - padding;
    return result > 0 ? result : 0.0;
  }
}
