import 'package:flutter/foundation.dart';

/// Sizes available for the progress indicators.
@immutable
class ProgressIndicatorSize {
  const ProgressIndicatorSize({
    required this.thickness,
    required this.diameterFlat,
    required this.diameterWavy,
  });

  /// Configurable fixed size variant.
  factory ProgressIndicatorSize.from({
    double? thickness,
    double? diameter,
  }) {
    final t = thickness ?? 4.0;
    final d = diameter ?? 40.0;
    return ProgressIndicatorSize(
      thickness: t,
      diameterFlat: d,
      diameterWavy: d + 8.0,
    );
  }

  /// The thickness for linear indicators.
  final double thickness;

  /// The diameter for circular indicators (flat shape).
  final double diameterFlat;

  /// The diameter for circular indicators (wavy shape).
  final double diameterWavy;

  /// Small size — 4dp linear thickness, 40dp circular flat diameter.
  static const ProgressIndicatorSize s = ProgressIndicatorSize(
    thickness: 4.0,
    diameterFlat: 40.0,
    diameterWavy: 48.0,
  );

  /// Medium size — 8dp linear thickness, 52dp circular flat diameter.
  ///
  /// Matches the spec's "thick" sample configuration
  /// (`md.comp.progress-indicator.circular.thick.size` = 52dp). The wavy
  /// container is derived from the baseline +8dp offset (48 = 40 + 8), so
  /// thick wavy = 52 + 8 = 60dp.
  static const ProgressIndicatorSize m = ProgressIndicatorSize(
    thickness: 8.0,
    diameterFlat: 52.0,
    diameterWavy: 60.0,
  );

  /// Alias for backward compatibility (equivalent to [s]).
  static const ProgressIndicatorSize fixed = s;

  /// Returns a scaled copy of this size.
  ///
  /// Manual utility for consumers; the progress indicator widgets do not
  /// apply this automatically (dimensions are fixed in logical pixels).
  ProgressIndicatorSize scaled(double scale) {
    if (scale == 1.0) return this;
    return ProgressIndicatorSize(
      thickness: thickness * scale,
      diameterFlat: diameterFlat * scale,
      diameterWavy: diameterWavy * scale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressIndicatorSize &&
          runtimeType == other.runtimeType &&
          thickness == other.thickness &&
          diameterFlat == other.diameterFlat &&
          diameterWavy == other.diameterWavy;

  @override
  int get hashCode => Object.hash(thickness, diameterFlat, diameterWavy);
}

/// Visual shape of the progress indicator.
///
/// - [flat]: a simple flat stroke for the progress.
/// - [wavy]: a wavy/squiggle appearance with continuous animation when
///   indeterminate or progress is complete.
enum ProgressIndicatorShape { flat, wavy }

/// Variant of the progress indicator.
enum ProgressIndicatorVariant { linear, circular }
