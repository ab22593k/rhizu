import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/styles/elevation/tokens.dart';

void main() {
  group('ElevationTokens', () {
    test('Level 0 should be 0.0dp', () {
      expect(ElevationTokens.level0, 0.0);
    });

    test('Level 1 should be 1.0dp', () {
      expect(ElevationTokens.level1, 1.0);
    });

    test('Level 2 should be 3.0dp', () {
      expect(ElevationTokens.level2, 3.0);
    });

    test('Level 3 should be 6.0dp', () {
      expect(ElevationTokens.level3, 6.0);
    });

    test('Level 4 should be 8.0dp', () {
      expect(ElevationTokens.level4, 8.0);
    });

    test('Level 5 should be 12.0dp', () {
      expect(ElevationTokens.level5, 12.0);
    });

    test('Scrim opacity should be 0.32', () {
      expect(ElevationTokens.scrimOpacity, 0.32);
    });
  });
}
