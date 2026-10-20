import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/foundation/layout/bento_delegate.dart';

BentoPacker _packer(
  List<BentoSpan> spans, {
  int crossAxisCount = 4,
}) {
  return BentoPacker(
    crossAxisCount: crossAxisCount,
    spanBuilder: (index) => spans[index],
  );
}

void _expectTile(
  BentoTileGeometry tile, {
  required int cross,
  required int main,
  required int crossSpan,
  required int mainSpan,
}) {
  expect(tile.crossAxisIndex, cross);
  expect(tile.mainAxisIndex, main);
  expect(tile.crossAxisSpan, crossSpan);
  expect(tile.mainAxisSpan, mainSpan);
}

void main() {
  group('BentoSpan', () {
    test('defaults to a single cell', () {
      const span = BentoSpan();
      expect(span.crossAxis, 1);
      expect(span.mainAxis, 1);
    });

    test('compares by span values', () {
      expect(
        const BentoSpan(crossAxis: 2, mainAxis: 3),
        const BentoSpan(crossAxis: 2, mainAxis: 3),
      );
      expect(
        const BentoSpan(crossAxis: 2).hashCode,
        const BentoSpan(crossAxis: 2).hashCode,
      );
    });
  });

  group('BentoPacker', () {
    test('packs single-cell tiles left to right, then wraps', () {
      final spans = List.filled(6, const BentoSpan());
      final packer = _packer(spans);

      _expectTile(
        packer.tileAt(0),
        cross: 0,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(1),
        cross: 1,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(2),
        cross: 2,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(3),
        cross: 3,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(4),
        cross: 0,
        main: 1,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(5),
        cross: 1,
        main: 1,
        crossSpan: 1,
        mainSpan: 1,
      );
    });

    test('a wide tile reserves its columns on the current row', () {
      final spans = [
        const BentoSpan(crossAxis: 2),
        const BentoSpan(),
        const BentoSpan(),
        const BentoSpan(),
      ];
      final packer = _packer(spans);

      _expectTile(
        packer.tileAt(0),
        cross: 0,
        main: 0,
        crossSpan: 2,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(1),
        cross: 2,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(2),
        cross: 3,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(3),
        cross: 0,
        main: 1,
        crossSpan: 1,
        mainSpan: 1,
      );
    });

    test('a tall tile pushes its column down', () {
      final spans = [
        const BentoSpan(mainAxis: 2),
        const BentoSpan(),
        const BentoSpan(),
        const BentoSpan(),
        const BentoSpan(),
      ];
      final packer = _packer(spans);

      _expectTile(
        packer.tileAt(0),
        cross: 0,
        main: 0,
        crossSpan: 1,
        mainSpan: 2,
      );
      _expectTile(
        packer.tileAt(1),
        cross: 1,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(2),
        cross: 2,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(3),
        cross: 3,
        main: 0,
        crossSpan: 1,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(4),
        cross: 1,
        main: 1,
        crossSpan: 1,
        mainSpan: 1,
      );
    });

    test('fills holes left by earlier spans', () {
      final spans = [
        const BentoSpan(crossAxis: 2),
        const BentoSpan(),
        const BentoSpan(),
        const BentoSpan(mainAxis: 2),
        const BentoSpan(crossAxis: 2),
        const BentoSpan(),
      ];
      final packer = _packer(spans);

      _expectTile(
        packer.tileAt(3),
        cross: 0,
        main: 1,
        crossSpan: 1,
        mainSpan: 2,
      );
      _expectTile(
        packer.tileAt(4),
        cross: 1,
        main: 1,
        crossSpan: 2,
        mainSpan: 1,
      );
      _expectTile(
        packer.tileAt(5),
        cross: 3,
        main: 1,
        crossSpan: 1,
        mainSpan: 1,
      );
    });

    test('clamps a span wider than the grid', () {
      final packer = _packer(
        [const BentoSpan(crossAxis: 5)],
        crossAxisCount: 3,
      );

      _expectTile(
        packer.tileAt(0),
        cross: 0,
        main: 0,
        crossSpan: 3,
        mainSpan: 1,
      );
      expect(packer.columnHeights, [1, 1, 1]);
    });

    test('resolves tiles lazily and caches each geometry', () {
      var calls = 0;
      final packer = BentoPacker(
        crossAxisCount: 4,
        spanBuilder: (index) {
          calls++;
          return const BentoSpan();
        },
      );

      packer.tileAt(2);
      expect(calls, 3);
      expect(packer.geometryCache.length, 3);

      packer.tileAt(2);
      packer.tileAt(1);
      expect(calls, 3);

      packer.tileAt(3);
      expect(calls, 4);
      expect(packer.geometryCache.length, 4);
    });

    test('clear drops cached geometry and column heights', () {
      var calls = 0;
      final packer = BentoPacker(
        crossAxisCount: 2,
        spanBuilder: (index) {
          calls++;
          return const BentoSpan();
        },
      );

      packer.tileAt(1);
      expect(packer.geometryCache, isNotEmpty);
      expect(packer.columnHeights, isNotEmpty);

      packer.clear();
      expect(packer.geometryCache, isEmpty);
      expect(packer.columnHeights, isEmpty);

      packer.tileAt(0);
      expect(calls, 3);
    });
  });
}
