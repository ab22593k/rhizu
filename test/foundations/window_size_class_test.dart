import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/foundations/window_size_class.dart';

void main() {
  group('WindowSizeClass', () {
    test('returns Compact for width < 600', () {
      expect(WindowSizeClass.fromWidth(0), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(599), WindowSizeClass.compact);
    });

    test('returns Medium for 600 <= width < 840', () {
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(839), WindowSizeClass.medium);
    });

    test('returns Expanded for 840 <= width < 1200', () {
      expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1199), WindowSizeClass.expanded);
    });

    test('returns Large for 1200 <= width < 1600', () {
      expect(WindowSizeClass.fromWidth(1200), WindowSizeClass.large);
      expect(WindowSizeClass.fromWidth(1599), WindowSizeClass.large);
    });

    test('returns ExtraLarge for width >= 1600', () {
      expect(WindowSizeClass.fromWidth(1600), WindowSizeClass.extraLarge);
      expect(WindowSizeClass.fromWidth(2000), WindowSizeClass.extraLarge);
    });
  });
}
