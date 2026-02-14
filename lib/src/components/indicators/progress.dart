import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/rhizu.dart';

export 'painter/progress_painter.dart';

enum CircularPISize { s, m }

enum LinearPISize { s, m }

enum PIShape { flat, wavy }

extension CircularPIExtension on CircularPISize {
  double get diameterWavy {
    switch (this) {
      case CircularPISize.s:
        return 48.0;
      case CircularPISize.m:
        return 52.0;
    }
  }

  double get diameterFlat {
    switch (this) {
      case CircularPISize.s:
        return 40.0;
      case CircularPISize.m:
        return 44.0;
    }
  }
}

class PI extends StatelessWidget {
  const PI({
    required this.value,
    super.key,
    this.size = CircularPISize.m,
    this.textStyle,
  });

  final double value;
  final CircularPISize size;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final d = size.diameterWavy;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularPI(value: value, size: size),
          Text(
            '${(value * 100).round()}%',
            style: textStyle ?? Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class CircularPI extends StatelessWidget {
  const CircularPI({
    super.key,
    this.value,
    this.size = CircularPISize.m,
    this.shape = PIShape.wavy,
    this.activeColor,
    this.trackColor,
    this.rotation = 0.0,
  });

  final double? value;
  final CircularPISize size;
  final PIShape shape;
  final Color? activeColor;
  final Color? trackColor;
  final double rotation;

  bool get _shouldAnimate {
    final v = value;
    return shape == PIShape.wavy &&
        (v == null || (v >= 1.0)) &&
        rotation == 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = activeColor ?? cs.primary;
    final track = trackColor ?? cs.onSurfaceVariant.withValues(alpha: 0.24);
    final wantsWavy = shape == PIShape.wavy;
    final diameter = wantsWavy ? size.diameterWavy : size.diameterFlat;

    return RepaintBoundary(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: _shouldAnimate
            ? RepeatingAnimationBuilder<double>(
                duration: const Duration(milliseconds: 3600),
                animatable: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  final rot = value * 2 * math.pi;
                  return CustomPaint(
                    painter: CircularWavyPainter(
                      value: this.value,
                      active: active,
                      track: track,
                      rotation: rot,
                    ),
                  );
                },
              )
            : CustomPaint(
                painter: wantsWavy
                    ? CircularWavyPainter(
                        value: value,
                        active: active,
                        track: track,
                        rotation: rotation,
                      )
                    : CircularFlatPainter(
                        value: value,
                        active: active,
                        track: track,
                        rotation: rotation,
                        size: size,
                      ),
              ),
      ),
    );
  }
}

class LinearPI extends StatelessWidget {
  const LinearPI({
    super.key,
    this.value,
    this.size = LinearPISize.m,
    this.shape = PIShape.wavy,
    this.activeColor,
    this.trackColor,
    this.phase = 0.0,
    this.inset = 4.0,
  });

  final double? value;
  final LinearPISize size;
  final PIShape shape;
  final Color? activeColor;
  final Color? trackColor;
  final double phase;
  final double inset;

  bool get _shouldAnimate {
    final v = value;
    return shape == PIShape.wavy && (v == null || (v >= 1.0)) && phase == 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Farben aus m3e_design beziehen (überschreibbar per Props)
    final active = ColorScheme.of(context).primary;
    final track = ColorScheme.of(context).surfaceContainerHighest;

    final spec = specForLinear(size: size, shape: shape);

    // Total height equals the taller of the two strokes sharing the same baseline.
    // For wavy, add vertical amplitude; for flat, it's just the trackHeight.
    final activeHeight = spec.isWavy
        ? (spec.trackHeight + 2 * spec.waveAmplitude)
        : spec.trackHeight;
    final totalHeight = activeHeight;

    return RepaintBoundary(
      child: SizedBox(
        height: totalHeight,
        width: double.infinity,
        child: _shouldAnimate
            ? RepeatingAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                animatable: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  final phaseValue = value * 2 * math.pi;
                  return CustomPaint(
                    painter: LinearPainter(
                      value: this.value,
                      spec: spec,
                      active: activeColor ?? active,
                      track: trackColor ?? track,
                      phase: phaseValue,
                      inset: inset,
                    ),
                  );
                },
              )
            : CustomPaint(
                painter: LinearPainter(
                  value: value,
                  spec: spec,
                  active: activeColor ?? active,
                  track: trackColor ?? track,
                  phase: phase,
                  inset: inset,
                ),
              ),
      ),
    );
  }
}

@immutable
class LinearSpecs {
  const LinearSpecs({
    required this.trackHeight,
    required this.gap,
    required this.dotDiameter,
    required this.dotOffset,
    required this.trailingMargin,
    required this.isWavy,
    this.waveAmplitude = 0,
    this.wavePeriod = 40,
  });

  final double trackHeight;
  final double gap;
  final double dotDiameter;
  final double dotOffset;
  final double trailingMargin;
  final bool isWavy;
  final double waveAmplitude;
  final double wavePeriod;
}

LinearSpecs specForLinear({
  required LinearPISize size,
  required PIShape shape,
}) => switch ((shape, size)) {
  (PIShape.flat, LinearPISize.s) => const LinearSpecs(
    trackHeight: 4,
    gap: 4,
    dotDiameter: 4,
    dotOffset: 4,
    trailingMargin: 4,
    isWavy: false,
  ),
  (PIShape.flat, LinearPISize.m) => const LinearSpecs(
    trackHeight: 8,
    gap: 4,
    dotDiameter: 4,
    dotOffset: 2,
    trailingMargin: 8,
    isWavy: false,
  ),
  (PIShape.wavy, LinearPISize.s) => const LinearSpecs(
    trackHeight: 4,
    gap: 4,
    dotDiameter: 4,
    dotOffset: 2,
    trailingMargin: 10,
    isWavy: true,
    waveAmplitude: 3,
  ),
  (PIShape.wavy, LinearPISize.m) => const LinearSpecs(
    trackHeight: 8,
    gap: 4,
    dotDiameter: 4,
    dotOffset: 2,
    trailingMargin: 14,
    isWavy: true,
    waveAmplitude: 3,
  ),
};

@Preview(name: 'Progress circular', size: Size.fromHeight(150))
Widget previewProgressCircular() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            PI(
              value: 0.25,
              size: CircularPISize.s,
            ),
            CircularPI(
              value: 0.5,
              shape: PIShape.flat,
            ),
          ],
        ),
      ),
    ),
  );
}

@Preview(name: 'Progress Linear', size: Size.fromHeight(200))
Widget previewProgressLinear() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .spaceEvenly,
          children: [
            SizedBox(
              width: 400,
              child: LinearPI(
                value: 0.6,
              ),
            ),
            SizedBox(
              width: 400,
              child: LinearPI(
                value: 0.9,
                shape: PIShape.flat,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
