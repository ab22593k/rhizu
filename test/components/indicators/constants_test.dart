import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/indicators/constants.dart';

void main() {
  group('LoadingIndicatorConstants', () {
    test('container size is 48.0', () {
      expect(LoadingIndicatorConstants.containerSize, equals(48.0));
    });

    test('indicator radius is 19.0', () {
      expect(LoadingIndicatorConstants.indicatorRadius, equals(19.0));
    });

    test('rotation duration is 4666ms', () {
      expect(
        LoadingIndicatorConstants.rotationDuration,
        equals(const Duration(milliseconds: 4666)),
      );
    });

    test('morph duration is 650ms', () {
      expect(
        LoadingIndicatorConstants.morphDuration,
        equals(const Duration(milliseconds: 650)),
      );
    });

    test('shape resolution is 120', () {
      expect(LoadingIndicatorConstants.shapeResolution, equals(120));
    });

    test('SVG viewport size is 380.0', () {
      expect(LoadingIndicatorConstants.svgViewportSize, equals(380.0));
    });

    test('SVG center is 190.0', () {
      expect(LoadingIndicatorConstants.svgCenter, equals(190.0));
    });

    test('SVG scale factor is calculated correctly', () {
      // scale factor = indicatorRadius / svgCenter = 19.0 / 190.0 = 0.1
      expect(LoadingIndicatorConstants.svgScaleFactor, equals(0.1));
    });

    test('SVG sample count is 1440', () {
      expect(LoadingIndicatorConstants.svgSampleCount, equals(1440));
    });

    test('indicator fits within container', () {
      // Indicator radius (19) * 2 = 38, which should be less than container size (48)
      expect(
        LoadingIndicatorConstants.indicatorRadius * 2,
        lessThan(LoadingIndicatorConstants.containerSize),
      );
    });

    // Responsive sizing tests
    test('min container size is 24.0', () {
      expect(LoadingIndicatorConstants.minContainerSize, equals(24.0));
    });

    test('max container size is 240.0', () {
      expect(LoadingIndicatorConstants.maxContainerSize, equals(240.0));
    });

    test('indicator to container ratio is correct', () {
      // 38.0 / 48.0 = 0.7916666666666666
      expect(
        LoadingIndicatorConstants.indicatorToContainerRatio,
        closeTo(0.7916, 0.0001),
      );
    });

    test('getIndicatorRadius returns correct values', () {
      // For default size 48.0, radius should be 19.0
      expect(
        LoadingIndicatorConstants.getIndicatorRadius(48.0),
        closeTo(19.0, 0.0001),
      );

      // For min size 24.0, radius should be 9.5
      expect(
        LoadingIndicatorConstants.getIndicatorRadius(24.0),
        closeTo(9.5, 0.0001),
      );

      // For max size 240.0, radius should be 95.0
      expect(
        LoadingIndicatorConstants.getIndicatorRadius(240.0),
        closeTo(95.0, 0.0001),
      );
    });

    test('getSvgScaleFactor returns correct values', () {
      // For default size 48.0, scale factor should be 0.1 (19.0 / 190.0)
      expect(
        LoadingIndicatorConstants.getSvgScaleFactor(48.0),
        closeTo(0.1, 0.0001),
      );

      // For min size 24.0, scale factor should be 0.05 (9.5 / 190.0)
      expect(
        LoadingIndicatorConstants.getSvgScaleFactor(24.0),
        closeTo(0.05, 0.0001),
      );
    });
  });

  group('WavyProgressConstants', () {
    test('default radius is 24.0', () {
      expect(WavyProgressConstants.defaultRadius, equals(24.0));
    });

    test('default stroke width is 4.0', () {
      expect(WavyProgressConstants.defaultStrokeWidth, equals(4.0));
    });

    test('default waves is 12', () {
      expect(WavyProgressConstants.defaultWaves, equals(12));
    });

    test('default amplitude is 2.0', () {
      expect(WavyProgressConstants.defaultAmplitude, equals(2.0));
    });

    test('default track gap is 4.0', () {
      expect(WavyProgressConstants.defaultTrackGap, equals(4.0));
    });

    test('rotation duration is 2 seconds', () {
      expect(
        WavyProgressConstants.rotationDuration,
        equals(const Duration(seconds: 2)),
      );
    });

    test('path step is 0.01', () {
      expect(WavyProgressConstants.pathStep, equals(0.01));
    });

    test('start angle offset is -pi/2', () {
      expect(
        WavyProgressConstants.startAngleOffset,
        equals(-1.5707963267948966),
      );
    });

    test('indeterminate tail length is 0.75', () {
      expect(WavyProgressConstants.indeterminateTailLength, equals(0.75));
    });

    test('track gap angle divisor is 4.0', () {
      expect(WavyProgressConstants.trackGapAngleDivisor, equals(4.0));
    });
  });
}
