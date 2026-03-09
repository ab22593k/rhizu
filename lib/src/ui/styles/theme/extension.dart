import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:rhizu/src/ui/styles/elevation/tokens.dart';
import 'package:rhizu/src/ui/styles/motion/tokens.dart';
import 'package:rhizu/src/ui/styles/shapes/tokens.dart';

@immutable
class RZElevation extends ThemeExtension<RZElevation> {
  const RZElevation({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
    required this.scrimOpacity,
  });

  factory RZElevation.fallback() {
    return const RZElevation(
      level0: ElevationTokens.level0,
      level1: ElevationTokens.level1,
      level2: ElevationTokens.level2,
      level3: ElevationTokens.level3,
      level4: ElevationTokens.level4,
      level5: ElevationTokens.level5,
      scrimOpacity: ElevationTokens.scrimOpacity,
    );
  }

  final double level0;
  final double level1;
  final double level2;
  final double level3;
  final double level4;
  final double level5;
  final double scrimOpacity;

  @override
  RZElevation copyWith({
    double? level0,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
    double? level5,
    double? scrimOpacity,
  }) {
    return RZElevation(
      level0: level0 ?? this.level0,
      level1: level1 ?? this.level1,
      level2: level2 ?? this.level2,
      level3: level3 ?? this.level3,
      level4: level4 ?? this.level4,
      level5: level5 ?? this.level5,
      scrimOpacity: scrimOpacity ?? this.scrimOpacity,
    );
  }

  @override
  RZElevation lerp(RZElevation? other, double t) {
    if (other == null) return this;
    return RZElevation(
      level0: lerpDouble(level0, other.level0, t)!,
      level1: lerpDouble(level1, other.level1, t)!,
      level2: lerpDouble(level2, other.level2, t)!,
      level3: lerpDouble(level3, other.level3, t)!,
      level4: lerpDouble(level4, other.level4, t)!,
      level5: lerpDouble(level5, other.level5, t)!,
      scrimOpacity: lerpDouble(scrimOpacity, other.scrimOpacity, t)!,
    );
  }
}

@immutable
class RZShape extends ThemeExtension<RZShape> {
  const RZShape({
    required this.cornerNone,
    required this.cornerExtraSmall,
    required this.cornerSmall,
    required this.cornerMedium,
    required this.cornerLarge,
    required this.cornerLargeIncreased,
    required this.cornerExtraLarge,
    required this.cornerExtraLargeIncreased,
    required this.cornerExtraExtraLarge,
    required this.cornerFull,
  });

  factory RZShape.fallback() {
    return const RZShape(
      cornerNone: ShapeTokens.cornerNone,
      cornerExtraSmall: ShapeTokens.cornerExtraSmall,
      cornerSmall: ShapeTokens.cornerSmall,
      cornerMedium: ShapeTokens.cornerMedium,
      cornerLarge: ShapeTokens.cornerLarge,
      cornerLargeIncreased: ShapeTokens.cornerLargeIncreased,
      cornerExtraLarge: ShapeTokens.cornerExtraLarge,
      cornerExtraLargeIncreased: ShapeTokens.cornerExtraLargeIncreased,
      cornerExtraExtraLarge: ShapeTokens.cornerExtraExtraLarge,
      cornerFull: ShapeTokens.cornerFull,
    );
  }

  final double cornerNone;
  final double cornerExtraSmall;
  final double cornerSmall;
  final double cornerMedium;
  final double cornerLarge;
  final double cornerLargeIncreased;
  final double cornerExtraLarge;
  final double cornerExtraLargeIncreased;
  final double cornerExtraExtraLarge;
  final double cornerFull;

  @override
  RZShape copyWith({
    double? cornerNone,
    double? cornerExtraSmall,
    double? cornerSmall,
    double? cornerMedium,
    double? cornerLarge,
    double? cornerLargeIncreased,
    double? cornerExtraLarge,
    double? cornerExtraLargeIncreased,
    double? cornerExtraExtraLarge,
    double? cornerFull,
  }) {
    return RZShape(
      cornerNone: cornerNone ?? this.cornerNone,
      cornerExtraSmall: cornerExtraSmall ?? this.cornerExtraSmall,
      cornerSmall: cornerSmall ?? this.cornerSmall,
      cornerMedium: cornerMedium ?? this.cornerMedium,
      cornerLarge: cornerLarge ?? this.cornerLarge,
      cornerLargeIncreased: cornerLargeIncreased ?? this.cornerLargeIncreased,
      cornerExtraLarge: cornerExtraLarge ?? this.cornerExtraLarge,
      cornerExtraLargeIncreased:
          cornerExtraLargeIncreased ?? this.cornerExtraLargeIncreased,
      cornerExtraExtraLarge:
          cornerExtraExtraLarge ?? this.cornerExtraExtraLarge,
      cornerFull: cornerFull ?? this.cornerFull,
    );
  }

  @override
  RZShape lerp(RZShape? other, double t) {
    if (other == null) return this;
    return RZShape(
      cornerNone: lerpDouble(cornerNone, other.cornerNone, t)!,
      cornerExtraSmall: lerpDouble(
        cornerExtraSmall,
        other.cornerExtraSmall,
        t,
      )!,
      cornerSmall: lerpDouble(cornerSmall, other.cornerSmall, t)!,
      cornerMedium: lerpDouble(cornerMedium, other.cornerMedium, t)!,
      cornerLarge: lerpDouble(cornerLarge, other.cornerLarge, t)!,
      cornerLargeIncreased: lerpDouble(
        cornerLargeIncreased,
        other.cornerLargeIncreased,
        t,
      )!,
      cornerExtraLarge: lerpDouble(
        cornerExtraLarge,
        other.cornerExtraLarge,
        t,
      )!,
      cornerExtraLargeIncreased: lerpDouble(
        cornerExtraLargeIncreased,
        other.cornerExtraLargeIncreased,
        t,
      )!,
      cornerExtraExtraLarge: lerpDouble(
        cornerExtraExtraLarge,
        other.cornerExtraExtraLarge,
        t,
      )!,
      cornerFull:
          lerpDouble(cornerFull, other.cornerFull, t) ?? double.infinity,
    );
  }
}

@immutable
class RZMotion extends ThemeExtension<RZMotion> {
  const RZMotion({
    required this.fastSpatial,
    required this.fastEffects,
    required this.defaultSpatial,
    required this.defaultEffects,
    required this.slowSpatial,
    required this.slowEffects,
  });

  factory RZMotion.fallback() {
    return RZMotion(
      fastSpatial: MotionTokens.expressiveFastSpatial,
      fastEffects: MotionTokens.expressiveFastEffects,
      defaultSpatial: MotionTokens.expressiveDefaultSpatial,
      defaultEffects: MotionTokens.expressiveDefaultEffects,
      slowSpatial: MotionTokens.expressiveSlowSpatial,
      slowEffects: MotionTokens.expressiveSlowEffects,
    );
  }

  final SpringDescription fastSpatial;
  final SpringDescription fastEffects;
  final SpringDescription defaultSpatial;
  final SpringDescription defaultEffects;
  final SpringDescription slowSpatial;
  final SpringDescription slowEffects;

  @override
  RZMotion copyWith({
    SpringDescription? fastSpatial,
    SpringDescription? fastEffects,
    SpringDescription? defaultSpatial,
    SpringDescription? defaultEffects,
    SpringDescription? slowSpatial,
    SpringDescription? slowEffects,
  }) {
    return RZMotion(
      fastSpatial: fastSpatial ?? this.fastSpatial,
      fastEffects: fastEffects ?? this.fastEffects,
      defaultSpatial: defaultSpatial ?? this.defaultSpatial,
      defaultEffects: defaultEffects ?? this.defaultEffects,
      slowSpatial: slowSpatial ?? this.slowSpatial,
      slowEffects: slowEffects ?? this.slowEffects,
    );
  }

  SpringDescription _lerpSpring(
    SpringDescription a,
    SpringDescription b,
    double t,
  ) {
    return SpringDescription(
      mass: lerpDouble(a.mass, b.mass, t)!,
      stiffness: lerpDouble(a.stiffness, b.stiffness, t)!,
      damping: lerpDouble(a.damping, b.damping, t)!,
    );
  }

  @override
  RZMotion lerp(RZMotion? other, double t) {
    if (other == null) return this;
    return RZMotion(
      fastSpatial: _lerpSpring(fastSpatial, other.fastSpatial, t),
      fastEffects: _lerpSpring(fastEffects, other.fastEffects, t),
      defaultSpatial: _lerpSpring(defaultSpatial, other.defaultSpatial, t),
      defaultEffects: _lerpSpring(defaultEffects, other.defaultEffects, t),
      slowSpatial: _lerpSpring(slowSpatial, other.slowSpatial, t),
      slowEffects: _lerpSpring(slowEffects, other.slowEffects, t),
    );
  }
}

/// A collection of structural design tokens used by widgets to obtain
/// standardized elevations, shapes and motion parameters.
///
/// Usage examples:
///
/// Providing the extension at the app level:
/// ```dart
/// final theme = ThemeData.light().copyWith(
///   extensions: <ThemeExtension<dynamic>>[
///     RZTheme.fallback(),
///   ],
/// );
///
/// MaterialApp(
///   theme: theme,
///   home: MyHome(),
/// );
/// ```
///
/// Reading values from the current theme in a widget:
/// ```dart
/// Widget build(BuildContext context) {
///   final expressive = Theme.of(context).extension<RZTheme>()!;
///
///   // Use shape/elevation/motion tokens:
///   final radius = expressive.shape.cornerMedium;
///   final elevation = expressive.elevation.level2;
///   final spring = expressive.motion.defaultSpatial;
///
///   return Container(
///     decoration: BoxDecoration(
///       borderRadius: BorderRadius.circular(radius),
///       // ...
///     ),
///     child: Material(
///       elevation: elevation,
///       // ...
///     ),
///   );
/// }
/// ```
///
/// Creating a modified copy of the extension and installing it back into the
/// app theme:
/// ```dart
/// final expressive = Theme.of(context).extension<RZTheme>()!;
/// final updatedExpressive = expressive.copyWith(
///   shape: expressive.shape.copyWith(cornerMedium: 12.0),
/// );
///
/// final newTheme = Theme.of(context).copyWith(
///   extensions: <ThemeExtension<dynamic>>[
///     updatedExpressive,
///   ],
/// );
///
/// // Rebuild the app or provide newTheme to MaterialApp to apply changes.
/// ```
@immutable
class RZTheme extends ThemeExtension<RZTheme> {
  const RZTheme({
    required this.elevation,
    required this.shape,
    required this.motion,
  });

  /// Creates an RZTheme with default structural values.
  factory RZTheme.fallback() {
    return RZTheme(
      elevation: RZElevation.fallback(),
      shape: RZShape.fallback(),
      motion: RZMotion.fallback(),
    );
  }

  final RZElevation elevation;
  final RZShape shape;
  final RZMotion motion;

  @override
  RZTheme copyWith({
    RZElevation? elevation,
    RZShape? shape,
    RZMotion? motion,
  }) {
    return RZTheme(
      elevation: elevation ?? this.elevation,
      shape: shape ?? this.shape,
      motion: motion ?? this.motion,
    );
  }

  @override
  RZTheme lerp(RZTheme? other, double t) {
    if (other == null) return this;
    return RZTheme(
      elevation: elevation.lerp(other.elevation, t),
      shape: shape.lerp(other.shape, t),
      motion: motion.lerp(other.motion, t),
    );
  }
}
