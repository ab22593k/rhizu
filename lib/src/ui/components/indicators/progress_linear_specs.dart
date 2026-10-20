import 'package:flutter/foundation.dart';

import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/progress_tokens.dart';

@immutable
class LinearSpecs {
  const LinearSpecs({
    required this.trackHeight,
    required this.gap,
    required this.dotDiameter,
    required this.isWavy,
    this.waveAmplitude = 0,
    this.wavePeriod = WavyProgressConstants.defaultWavePeriod,
    this.indeterminateWavePeriod =
        WavyProgressConstants.indeterminateWavePeriod,
  });

  /// Stroke height of active / track lines.
  final double trackHeight;

  /// Horizontal gap between active track end and inactive track start.
  /// Spec: track-active-indicator-space = 4dp (fixed).
  final double gap;

  /// Diameter of the stop indicator dot (always 4dp).
  final double dotDiameter;

  /// Whether the active track uses a wavy path.
  final bool isWavy;

  /// Peak-to-center amplitude of the wave (spec: 3dp).
  final double waveAmplitude;

  /// Wavelength of the wave (spec: 40dp).
  final double wavePeriod;

  /// Wavelength of the wave in indeterminate mode (spec: 20dp).
  final double indeterminateWavePeriod;
}

/// Builds [LinearSpecs] from the unified [ProgressIndicatorSize] and shape.
///
/// Measurements from the merged M3 progress indicator token set
/// (`md.comp.progress-indicator.linear`):
///
/// | Variant      | Height | Gap | dot⌀ | amp | λ    | λ(indet) |
/// |--------------|--------|-----|------|-----|------|----------|
/// | Flat  small  | 4      | 4   | 4    | —   | —    | —        |
/// | Flat  medium | 8      | 4   | 4    | —   | —    | —        |
/// | Wavy  small  | 10     | 4   | 4    | 3   | 40   | 20       |
/// | Wavy  medium | 14     | 4   | 4    | 3   | 40   | 20       |
///
/// Wavy indicators use [amplitude] and [wavelength] to determine the shape of
/// the wave; the wave's peak-to-trough extent
/// (`trackHeight + 2 × amplitude`) is the overall container height. Pass either
/// override to replace the spec default (3dp amplitude, 40dp determinate /
/// 20dp indeterminate wavelength).
LinearSpecs specForLinear({
  required ProgressIndicatorSize size,
  required ProgressIndicatorShape shape,
  double scale = 1.0,
  double? amplitude,
  double? wavelength,
}) {
  final thickness = size.thickness;
  // Shared derived measurements.
  final dotDiameter = 4.0 * scale;
  final gap = 4.0 * scale;

  switch (shape) {
    case ProgressIndicatorShape.flat:
      return LinearSpecs(
        trackHeight: thickness,
        gap: gap,
        dotDiameter: dotDiameter,
        isWavy: false,
      );
    case ProgressIndicatorShape.wavy:
      // A custom wavelength replaces the determinate (40dp) and indeterminate
      // (20dp) wavelengths alike; negative amplitudes flatten the wave and a
      // non-positive wavelength would break the wave period, so both are
      // clamped defensively.
      final effectiveAmplitude =
          (amplitude ?? WavyProgressConstants.defaultAmplitude).clamp(
            0.0,
            double.infinity,
          );
      final customWavelength = wavelength;
      final effectiveWavelength =
          (customWavelength ?? WavyProgressConstants.defaultWavePeriod).clamp(
            1.0,
            double.infinity,
          );
      final effectiveIndeterminateWavelength = customWavelength == null
          ? WavyProgressConstants.indeterminateWavePeriod
          : effectiveWavelength;
      return LinearSpecs(
        trackHeight: thickness,
        gap: gap,
        dotDiameter: dotDiameter,
        isWavy: true,
        waveAmplitude: effectiveAmplitude * scale,
        wavePeriod: effectiveWavelength * scale,
        indeterminateWavePeriod: effectiveIndeterminateWavelength * scale,
      );
  }
}
