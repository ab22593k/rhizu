import 'package:flutter/material.dart';

import 'package:rhizu/src/contracts/indicators/shape_contract.dart';

/// Defines how the loading indicator is visually contained.
///
/// This affects both the background styling and the color
/// scheme applied to the indicator.
enum Containment {
  /// Simple loading indicator without a container.
  ///
  /// Uses the theme's primary color for the indicator.
  /// No background container is shown.
  simple,

  /// Contained loading indicator with a circular container.
  ///
  /// Uses the theme's primaryContainer color for the background
  /// and onPrimaryContainer color for the indicator.
  contained,
}

/// Contract for loading indicator behavior.
///
/// This defines the interface that all loading indicator
/// implementations must follow.
abstract class LoadingIndicatorContract {
  /// The size of the loading indicator in logical pixels.
  double get size;

  /// How the indicator should be visually contained.
  Containment get containment;

  /// The sequence of shapes to morph through.
  List<ShapeType> get shapeSequence;

  /// Creates a widget that implements this contract.
  Widget buildWidget(BuildContext context);
}

/// Constants for loading indicator dimensions.
class LoadingIndicatorConstants {
  LoadingIndicatorConstants._();

  /// Minimum container size (24.0).
  static const double minContainerSize = 24.0;

  /// Default container size (48.0).
  static const double defaultContainerSize = 48.0;

  /// Maximum container size (240.0).
  static const double maxContainerSize = 240.0;

  /// Resolution for shape morphing (number of points).
  static const int shapeResolution = 64;
}
