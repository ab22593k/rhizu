import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('ExpressiveRadius', () {
    test('provides correct corner radii', () {
      expect(RZRadius.none, BorderRadius.zero);
      expect(
        RZRadius.extraSmall,
        const BorderRadius.all(Radius.circular(4)),
      );
      expect(
        RZRadius.small,
        const BorderRadius.all(Radius.circular(8)),
      );
      expect(
        RZRadius.medium,
        const BorderRadius.all(Radius.circular(12)),
      );
      expect(
        RZRadius.large,
        const BorderRadius.all(Radius.circular(16)),
      );
      expect(
        RZRadius.extraLarge,
        const BorderRadius.all(Radius.circular(28)),
      );
      expect(
        RZRadius.full,
        const BorderRadius.all(Radius.circular(9999)),
      );
    });
  });
}
