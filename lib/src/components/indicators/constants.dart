/// Constants used throughout the loading indicator component.
///
/// This class centralizes all magic numbers and configuration values
/// to make them easier to maintain and customize.
class LoadingIndicatorConstants {
  const LoadingIndicatorConstants._();

  // ============================================================================
  // Dimensions
  // ============================================================================

  /// The size of the loading indicator container in logical pixels.
  ///
  /// The container provides space for the animated indicator and any
  /// background styling (e.g., for contained mode).
  static const double containerSize = 48.0;

  /// The radius of the active loading indicator in logical pixels.
  ///
  /// The indicator occupies 38dp within the 48dp container,
  /// so the radius is 38 / 2 = 19.0.
  static const double indicatorRadius = 19.0;

  // ============================================================================
  // Animation Timing
  // ============================================================================

  /// Duration for one complete rotation of the loading indicator.
  ///
  /// The indicator rotates 360 degrees over this duration.
  /// Value: 4666 milliseconds
  static const Duration rotationDuration = Duration(milliseconds: 4666);

  /// Duration for morphing between two shapes.
  ///
  /// Each shape transition takes this amount of time.
  /// Value: 650 milliseconds
  static const Duration morphDuration = Duration(milliseconds: 650);

  // ============================================================================
  // Rendering
  // ============================================================================

  /// Number of segments to use when rendering the morphing shape.
  ///
  /// Higher values produce smoother shapes but require more computation.
  /// Value: 120 segments (3 degrees per segment)
  static const int shapeResolution = 120;

  // ============================================================================
  // SVG Parsing
  // ============================================================================

  /// The size of the SVG viewport used for shape definitions.
  ///
  /// All shape SVGs are defined in a square viewport of this size.
  static const double svgViewportSize = 380.0;

  /// The center point of the SVG viewport.
  ///
  /// Shapes are centered at this coordinate in SVG space.
  static const double svgCenter = 190.0;

  /// Scale factor to convert from SVG coordinates to local coordinates.
  ///
  /// Calculated as: indicatorRadius / svgCenter = 19.0 / 190.0 = 0.1
  static const double svgScaleFactor = 0.1;

  /// Number of samples to take when parsing an SVG path into polar coordinates.
  ///
  /// Using 4 samples per degree (1440 total) provides high accuracy.
  static const int svgSampleCount = 1440;
}

/// Constants used throughout the wavy circular progress indicator component.
///
/// This class centralizes all default values and configuration parameters
/// to make them easier to maintain and customize.
class WavyProgressConstants {
  const WavyProgressConstants._();

  // ============================================================================
  // Dimensions
  // ============================================================================

  /// Default radius of the progress indicator in logical pixels.
  ///
  /// The total widget size will be radius * 2.
  static const double defaultRadius = 24.0;

  /// Default stroke width for the indicator lines in logical pixels.
  static const double defaultStrokeWidth = 4.0;

  // ============================================================================
  // Wave Appearance
  // ============================================================================

  /// Default number of waves (frequency) around the circle.
  ///
  /// Higher values create more peaks and troughs in the wave pattern.
  static const int defaultWaves = 12;

  /// Default amplitude (height) of the wave in logical pixels.
  ///
  /// This determines how far the wave deviates from the base radius.
  static const double defaultAmplitude = 2.0;

  // ============================================================================
  // Track Configuration
  // ============================================================================

  /// Default gap between the active indicator and track in logical pixels.
  static const double defaultTrackGap = 4.0;

  /// Gap angle calculation divisor.
  ///
  /// Used to convert track gap distance to angle for determinate mode.
  static const double trackGapAngleDivisor = 4.0;

  // ============================================================================
  // Animation
  // ============================================================================

  /// Duration for one complete rotation in indeterminate mode.
  static const Duration rotationDuration = Duration(seconds: 2);

  // ============================================================================
  // Path Generation
  // ============================================================================

  /// Step size for path generation (resolution of the curve).
  ///
  /// Smaller values create smoother curves but require more computation.
  static const double pathStep = 0.01;

  /// Start angle offset to begin drawing from the top (-90 degrees).
  static const double startAngleOffset = -1.5707963267948966; // -pi/2

  // ============================================================================
  // Indeterminate Mode
  // ============================================================================

  /// Length of the active indicator arc in indeterminate mode (as fraction of circle).
  ///
  /// Value of 0.75 means the active arc covers 75% of the circle.
  static const double indeterminateTailLength = 0.75;
}
