import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/buttons/button_group_geometry.dart';
import 'package:rhizu/src/ui/components/buttons/button_group_tokens.dart';

const _natural = [100.0, 100.0, 100.0];

ButtonGroupGeometry _geometry({
  ButtonGroupSize size = ButtonGroupSize.md,
  ButtonGroupVariant variant = ButtonGroupVariant.standard,
  ButtonGroupShape shape = ButtonGroupShape.round,
  Axis direction = Axis.horizontal,
  TextDirection textDirection = TextDirection.ltr,
  int itemCount = 3,
  bool expanded = false,
}) {
  return ButtonGroupGeometry(
    size: size,
    variant: variant,
    shape: shape,
    direction: direction,
    textDirection: textDirection,
    itemCount: itemCount,
    expanded: expanded,
  );
}

void _expectRadii(
  ButtonGroupRadii actual,
  double tl,
  double tr,
  double bl,
  double br,
) {
  expect(actual.tl, Radius.circular(tl));
  expect(actual.tr, Radius.circular(tr));
  expect(actual.bl, Radius.circular(bl));
  expect(actual.br, Radius.circular(br));
}

void main() {
  group('ButtonGroupGeometry', () {
    group('configuration', () {
      test('standard groups are fixed unless expanded', () {
        expect(_geometry().isFlexible, isFalse);
        expect(_geometry(expanded: true).isFlexible, isTrue);
      });

      test('connected groups are always flexible', () {
        expect(
          _geometry(variant: ButtonGroupVariant.connected).isFlexible,
          isTrue,
        );
        expect(
          _geometry(
            variant: ButtonGroupVariant.connected,
            expanded: true,
          ).isFlexible,
          isTrue,
        );
      });

      test('connected groups use a 2dp gap', () {
        expect(
          _geometry(variant: ButtonGroupVariant.connected).gap,
          2,
        );
      });

      test('standard groups use the size gap token', () {
        expect(_geometry(size: ButtonGroupSize.xs).gap, 18);
        expect(_geometry(size: ButtonGroupSize.sm).gap, 12);
        expect(_geometry().gap, 8);
        expect(_geometry(size: ButtonGroupSize.lg).gap, 8);
        expect(_geometry(size: ButtonGroupSize.xl).gap, 8);
      });

      test('overflow button width is icon plus horizontal padding', () {
        final geometry = _geometry();
        expect(
          geometry.overflowButtonWidth,
          geometry.size.iconSize + geometry.size.padding.horizontal,
        );
      });

      test('rtl only applies to horizontal groups', () {
        expect(
          _geometry(textDirection: TextDirection.rtl).isRtl,
          isTrue,
        );
        expect(
          _geometry(
            direction: Axis.vertical,
            textDirection: TextDirection.rtl,
          ).isRtl,
          isFalse,
        );
      });
    });

    group('widthFor', () {
      test('returns null for flexible groups', () {
        expect(
          _geometry(
            variant: ButtonGroupVariant.connected,
          ).widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 0,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          isNull,
        );
        expect(
          _geometry(expanded: true).widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 0,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          isNull,
        );
      });

      test('returns null before measurement, at rest, or without a press', () {
        final geometry = _geometry();
        expect(
          geometry.widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 0,
            naturalWidths: _natural,
            widthsMeasured: false,
          ),
          isNull,
        );
        expect(
          geometry.widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: null,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          isNull,
        );
        expect(
          geometry.widthFor(
            index: 0,
            pressProgress: 0,
            pressedIndex: 0,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          isNull,
        );
      });

      test('pressed button grows by 15% at full progress', () {
        expect(
          _geometry().widthFor(
            index: 1,
            pressProgress: 1,
            pressedIndex: 1,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          closeTo(115, 1e-9),
        );
      });

      test('pressed button growth follows press progress', () {
        expect(
          _geometry().widthFor(
            index: 1,
            pressProgress: 0.5,
            pressedIndex: 1,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          closeTo(107.5, 1e-9),
        );
      });

      test('two neighbors split the growth equally', () {
        expect(
          _geometry().widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 1,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          closeTo(92.5, 1e-9),
        );
      });

      test('a single neighbor gives up at most 10%', () {
        expect(
          _geometry().widthFor(
            index: 1,
            pressProgress: 1,
            pressedIndex: 0,
            naturalWidths: _natural,
            widthsMeasured: true,
          ),
          closeTo(90, 1e-9),
        );
      });

      test('non-adjacent buttons keep their natural width', () {
        expect(
          _geometry(itemCount: 5).widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 2,
            naturalWidths: const [100, 100, 100, 100, 100],
            widthsMeasured: true,
          ),
          100,
        );
      });

      test('neighbor shrink scales with the pressed natural width', () {
        expect(
          _geometry().widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 1,
            naturalWidths: const [200, 200, 200],
            widthsMeasured: true,
          ),
          closeTo(185, 1e-9),
        );
      });

      test('returns natural width when the pressed width is missing', () {
        expect(
          _geometry().widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 1,
            naturalWidths: const [100, null, 100],
            widthsMeasured: true,
          ),
          100,
        );
      });

      test('returns null when the index has no measured width', () {
        expect(
          _geometry().widthFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 1,
            naturalWidths: const [null, 100, 100],
            widthsMeasured: true,
          ),
          isNull,
        );
      });
    });

    group('flexFor', () {
      test('connected groups never morph their shares', () {
        final geometry = _geometry(variant: ButtonGroupVariant.connected);
        for (final index in [0, 1, 2]) {
          expect(
            geometry.flexFor(
              index: index,
              pressProgress: 1,
              pressedIndex: 0,
            ),
            ButtonGroupGeometry.flexBase,
          );
        }
      });

      test('all buttons get an equal share at rest', () {
        expect(
          _geometry().flexFor(
            index: 0,
            pressProgress: 0,
            pressedIndex: null,
          ),
          ButtonGroupGeometry.flexBase,
        );
      });

      test('pressed button gains 15% flex', () {
        expect(
          _geometry().flexFor(
            index: 1,
            pressProgress: 1,
            pressedIndex: 1,
          ),
          1150,
        );
      });

      test('neighbors give up their share of the growth', () {
        expect(
          _geometry().flexFor(
            index: 0,
            pressProgress: 1,
            pressedIndex: 1,
          ),
          925,
        );
      });

      test('a lone neighbor gives up 15%', () {
        expect(
          _geometry().flexFor(
            index: 1,
            pressProgress: 1,
            pressedIndex: 0,
          ),
          850,
        );
      });

      test('neighbor share is rounded to the nearest integer', () {
        expect(
          _geometry().flexFor(
            index: 0,
            pressProgress: 0.5,
            pressedIndex: 1,
          ),
          963,
        );
      });

      test('neighbor share never drops below 100', () {
        expect(
          _geometry().flexFor(
            index: 0,
            pressProgress: 30,
            pressedIndex: 1,
          ),
          100,
        );
      });
    });

    group('radiiFor', () {
      test('round standard buttons are pills at rest', () {
        _expectRadii(
          _geometry().radiiFor(
            index: 0,
            pressProgress: 0,
            selectionMorph: 0,
          ),
          28,
          28,
          28,
          28,
        );
      });

      test('square standard buttons use the inner corner at rest', () {
        _expectRadii(
          _geometry(shape: ButtonGroupShape.square).radiiFor(
            index: 0,
            pressProgress: 0,
            selectionMorph: 0,
          ),
          8,
          8,
          8,
          8,
        );
      });

      test('pressed middle button flattens its inner corners', () {
        _expectRadii(
          _geometry().radiiFor(
            index: 1,
            pressProgress: 1,
            selectionMorph: 0,
          ),
          4,
          4,
          4,
          4,
        );
      });

      test('pressed first button keeps its leading outer corner', () {
        _expectRadii(
          _geometry().radiiFor(
            index: 0,
            pressProgress: 1,
            selectionMorph: 0,
          ),
          28,
          4,
          28,
          4,
        );
      });

      test('pressed last button keeps its trailing outer corner', () {
        _expectRadii(
          _geometry().radiiFor(
            index: 2,
            pressProgress: 1,
            selectionMorph: 0,
          ),
          4,
          28,
          4,
          28,
        );
      });

      test('selected round buttons swap to the square corner', () {
        _expectRadii(
          _geometry().radiiFor(
            index: 1,
            pressProgress: 0,
            selectionMorph: 1,
          ),
          8,
          8,
          8,
          8,
        );
      });

      test('selected square buttons swap to the pill corner', () {
        _expectRadii(
          _geometry(shape: ButtonGroupShape.square).radiiFor(
            index: 1,
            pressProgress: 0,
            selectionMorph: 1,
          ),
          28,
          28,
          28,
          28,
        );
      });

      test('selection morph interpolates the corner radius', () {
        _expectRadii(
          _geometry().radiiFor(
            index: 1,
            pressProgress: 0,
            selectionMorph: 0.5,
          ),
          18,
          18,
          18,
          18,
        );
      });

      test('connected first button faces the group with inner corners', () {
        _expectRadii(
          _geometry(
            variant: ButtonGroupVariant.connected,
          ).radiiFor(
            index: 0,
            pressProgress: 0,
            selectionMorph: 0,
          ),
          28,
          8,
          28,
          8,
        );
      });

      test('connected middle button uses inner corners everywhere', () {
        _expectRadii(
          _geometry(
            variant: ButtonGroupVariant.connected,
          ).radiiFor(
            index: 1,
            pressProgress: 0,
            selectionMorph: 0,
          ),
          8,
          8,
          8,
          8,
        );
      });

      test('connected last button keeps its trailing outer corner', () {
        _expectRadii(
          _geometry(
            variant: ButtonGroupVariant.connected,
          ).radiiFor(
            index: 2,
            pressProgress: 0,
            selectionMorph: 0,
          ),
          8,
          28,
          8,
          28,
        );
      });

      test('connected selected button becomes fully rounded', () {
        _expectRadii(
          _geometry(
            variant: ButtonGroupVariant.connected,
          ).radiiFor(
            index: 1,
            pressProgress: 0,
            selectionMorph: 1,
          ),
          28,
          28,
          28,
          28,
        );
      });

      test('rtl mirrors the leading and trailing corners', () {
        _expectRadii(
          _geometry(textDirection: TextDirection.rtl).radiiFor(
            index: 0,
            pressProgress: 1,
            selectionMorph: 0,
          ),
          4,
          28,
          4,
          28,
        );
      });

      test('vertical buttons stack leading on top of trailing', () {
        _expectRadii(
          _geometry(direction: Axis.vertical).radiiFor(
            index: 0,
            pressProgress: 1,
            selectionMorph: 0,
          ),
          28,
          28,
          4,
          4,
        );
      });
    });

    group('overflowRadii', () {
      test('standard overflow button uses the outer shape everywhere', () {
        _expectRadii(
          _geometry().overflowRadii(),
          28,
          28,
          28,
          28,
        );
      });

      test('connected overflow button faces the group', () {
        _expectRadii(
          _geometry(
            variant: ButtonGroupVariant.connected,
          ).overflowRadii(),
          8,
          28,
          8,
          28,
        );
      });

      test('connected overflow button mirrors in rtl', () {
        _expectRadii(
          _geometry(
            variant: ButtonGroupVariant.connected,
            textDirection: TextDirection.rtl,
          ).overflowRadii(),
          28,
          8,
          28,
          8,
        );
      });

      test('vertical connected overflow button stacks its corners', () {
        _expectRadii(
          _geometry(
            variant: ButtonGroupVariant.connected,
            direction: Axis.vertical,
          ).overflowRadii(),
          8,
          8,
          28,
          28,
        );
      });

      test('square standard overflow button uses the inner corner', () {
        _expectRadii(
          _geometry(shape: ButtonGroupShape.square).overflowRadii(),
          8,
          8,
          8,
          8,
        );
      });
    });

    group('overflowFitCount', () {
      test('returns null when every button fits', () {
        expect(
          ButtonGroupGeometry.overflowFitCount(
            widths: const [100, 100, 100],
            availableWidth: 1000,
            gap: 8,
            overflowWidth: 40,
          ),
          isNull,
        );
      });

      test('returns null for a single button', () {
        expect(
          ButtonGroupGeometry.overflowFitCount(
            widths: const [100],
            availableWidth: 10,
            gap: 8,
            overflowWidth: 40,
          ),
          isNull,
        );
      });

      test('returns null for no buttons', () {
        expect(
          ButtonGroupGeometry.overflowFitCount(
            widths: const [],
            availableWidth: 10,
            gap: 8,
            overflowWidth: 40,
          ),
          isNull,
        );
      });

      test('collapses everything when nothing fits next to the menu', () {
        expect(
          ButtonGroupGeometry.overflowFitCount(
            widths: const [100, 100, 100],
            availableWidth: 100,
            gap: 8,
            overflowWidth: 40,
          ),
          0,
        );
      });

      test('counts the leading buttons that fit including gaps', () {
        expect(
          ButtonGroupGeometry.overflowFitCount(
            widths: const [100, 100, 100],
            availableWidth: 200,
            gap: 8,
            overflowWidth: 40,
          ),
          1,
        );
      });

      test('stops before a button that would overflow', () {
        expect(
          ButtonGroupGeometry.overflowFitCount(
            widths: const [100, 100, 100, 100],
            availableWidth: 350,
            gap: 8,
            overflowWidth: 40,
          ),
          2,
        );
      });
    });
  });
}
