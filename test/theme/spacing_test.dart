import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  group('ExpressiveSpacing', () {
    test('returns correct margin for Compact', () {
      expect(ExpressiveSpacing.margin(WindowSizeClass.compact), 16.0);
    });

    test('returns correct margin for Medium', () {
      expect(ExpressiveSpacing.margin(WindowSizeClass.medium), 24.0);
    });

    test('returns correct margin for Expanded and up', () {
      expect(ExpressiveSpacing.margin(WindowSizeClass.expanded), 32.0);
      expect(ExpressiveSpacing.margin(WindowSizeClass.large), 32.0);
      expect(ExpressiveSpacing.margin(WindowSizeClass.extraLarge), 32.0);
    });
  });
}
