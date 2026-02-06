import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('ExpressiveRadius', () {
    test('provides correct corner radii', () {
      expect(ExpressiveRadius.none, BorderRadius.zero);
      expect(
        ExpressiveRadius.extraSmall,
        const BorderRadius.all(Radius.circular(4)),
      );
      expect(
        ExpressiveRadius.small,
        const BorderRadius.all(Radius.circular(8)),
      );
      expect(
        ExpressiveRadius.medium,
        const BorderRadius.all(Radius.circular(12)),
      );
      expect(
        ExpressiveRadius.large,
        const BorderRadius.all(Radius.circular(16)),
      );
      expect(
        ExpressiveRadius.extraLarge,
        const BorderRadius.all(Radius.circular(28)),
      );
      expect(
        ExpressiveRadius.full,
        const BorderRadius.all(Radius.circular(9999)),
      );
    });
  });
}
