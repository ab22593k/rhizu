import 'package:flutter_test/flutter_test.dart';

import 'package:rhizu/src/ui/components/indicators/shapes/polar_shape.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_asset_store.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_type.dart';
import 'package:rhizu/src/ui/styles/shapes/static.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShapeAssetStore.extractSvgPathData', () {
    test('extracts the d attribute from an SVG document', () {
      const svg =
          '<svg viewBox="0 0 380 380"><path fill="#FFFFFF" d="M0 0 L1 1 Z"/></svg>';
      expect(ShapeAssetStore.extractSvgPathData(svg), 'M0 0 L1 1 Z');
    });

    test('throws a FormatException when no d attribute is present', () {
      expect(
        () => ShapeAssetStore.extractSvgPathData('<svg></svg>'),
        throwsFormatException,
      );
    });
  });

  group('ShapeAssetStore', () {
    test('throws a StateError before prewarm', () {
      expect(
        () => ShapeAssetStore.shapeFor(RZShapes.softBurst),
        throwsStateError,
      );
    });

    test(
      'loads every shape from its asset and serves it synchronously',
      () async {
        await ShapeAssetStore.prewarm(
          ShapeType.values.map((type) => type.assetPath),
        );

        for (final type in ShapeType.values) {
          final shape = ShapeAssetStore.shapeFor(type.assetPath);
          expect(shape, isA<PolarShape>());
          expect(shape.radii.length, equals(360));
          expect(shape.radii.any((r) => r > 0), isTrue);
          // Not a uniform circle: guards against a broken extraction that
          // `_fillGaps` would silently backfill with the default radius.
          expect(shape.radii.toSet().length, greaterThan(1));
          expect(ShapeAssetStore.isReadyFor(type.assetPath), isTrue);
        }
      },
    );

    test('caches shapes across lookups', () async {
      await ShapeAssetStore.prewarm([RZShapes.softBurst]);

      final first = ShapeAssetStore.shapeFor(RZShapes.softBurst);
      final second = ShapeAssetStore.shapeFor(RZShapes.softBurst);

      expect(identical(first, second), isTrue);
    });
  });
}
