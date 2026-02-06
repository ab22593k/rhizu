import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/indicators/animation/spring_curve.dart';

void main() {
  group('SpringCurve', () {
    test('transform returns value in reasonable range', () {
      const curve = SpringCurve();

      // Test at various points
      for (double t = 0.0; t <= 1.0; t += 0.1) {
        final value = curve.transform(t);
        expect(value, greaterThanOrEqualTo(-0.2)); // Allow undershoot
        expect(value, lessThanOrEqualTo(1.2)); // Allow overshoot
      }
    });

    test('transform returns 0 at t=0', () {
      const curve = SpringCurve();
      expect(curve.transform(0.0), equals(0.0));
    });

    test('transform returns approximately 1 at t=1', () {
      const curve = SpringCurve();
      // Spring curves may overshoot, so we check it's close to 1
      expect(curve.transform(1.0), closeTo(1.0, 0.2));
    });

    test('transform is monotonic (generally increasing)', () {
      const curve = SpringCurve();
      double previousValue = 0.0;

      // Check that values generally increase (allowing for small spring oscillations)
      for (double t = 0.1; t <= 1.0; t += 0.1) {
        final value = curve.transform(t);
        // The curve should generally move forward despite spring oscillations
        expect(value, greaterThan(previousValue - 0.2));
        previousValue = value;
      }
    });

    test('has spring-like behavior with overshoot', () {
      const curve = SpringCurve();

      // A spring curve typically overshoots around 0.6-0.8
      final values = <double>[];
      for (double t = 0.0; t <= 1.0; t += 0.05) {
        values.add(curve.transform(t));
      }

      // Find the maximum value
      final maxValue = values.reduce((a, b) => a > b ? a : b);

      // Spring should overshoot target (1.0) at some point
      expect(maxValue, greaterThan(1.0));
    });
  });
}
