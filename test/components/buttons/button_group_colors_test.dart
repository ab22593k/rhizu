import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/buttons/button_group_colors.dart';
import 'package:rhizu/src/ui/components/buttons/button_group_tokens.dart';

const _scheme = ColorScheme.light();

ButtonGroupPalette _palette({
  ButtonGroupStyle style = ButtonGroupStyle.tonal,
  Color? selectedColor,
  Color? unselectedColor,
  Color? legacyColor,
}) {
  return ButtonGroupPalette(
    style: style,
    selectedColor: selectedColor,
    unselectedColor: unselectedColor,
    legacyColor: legacyColor,
  );
}

void main() {
  group('ButtonGroupPalette', () {
    group('contrastRatio', () {
      test('black on white is the maximum ratio', () {
        expect(
          ButtonGroupPalette.contrastRatio(Colors.black, Colors.white),
          closeTo(21, 1e-9),
        );
      });

      test('a color against itself has a ratio of one', () {
        expect(
          ButtonGroupPalette.contrastRatio(Colors.teal, Colors.teal),
          closeTo(1, 1e-9),
        );
      });

      test('is symmetric', () {
        expect(
          ButtonGroupPalette.contrastRatio(Colors.black, Colors.teal),
          ButtonGroupPalette.contrastRatio(Colors.teal, Colors.black),
        );
      });
    });

    group('onColorFor', () {
      test('uses black on white', () {
        expect(ButtonGroupPalette.onColorFor(Colors.white), Colors.black);
      });

      test('uses white on black', () {
        expect(ButtonGroupPalette.onColorFor(Colors.black), Colors.white);
      });

      test('picks the higher contrast option on mid gray', () {
        const gray = Color(0xFF808080);
        expect(
          ButtonGroupPalette.contrastRatio(gray, Colors.black),
          greaterThan(
            ButtonGroupPalette.contrastRatio(gray, Colors.white),
          ),
        );
        expect(ButtonGroupPalette.onColorFor(gray), Colors.black);
      });

      test('picks white on a dark surface', () {
        expect(
          ButtonGroupPalette.onColorFor(const Color(0xFF303030)),
          Colors.white,
        );
      });

      test('picks black on a light surface', () {
        expect(
          ButtonGroupPalette.onColorFor(const Color(0xFFF0F0F0)),
          Colors.black,
        );
      });
    });

    group('built-in styles', () {
      test('filled selected uses the primary container', () {
        final colors = _palette(
          style: ButtonGroupStyle.filled,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.background, _scheme.primary);
        expect(colors.foreground, _scheme.onPrimary);
        expect(colors.border, _scheme.outline);
        expect(colors.elevation, 0);
      });

      test('filled unselected uses the surface container', () {
        final colors = _palette(
          style: ButtonGroupStyle.filled,
        ).resolve(_scheme, selected: false, disabled: false);
        expect(colors.background, _scheme.surfaceContainerHighest);
        expect(colors.foreground, _scheme.onSurface);
        expect(colors.border, _scheme.outline);
        expect(colors.elevation, 0);
      });

      test('tonal selected uses the secondary container', () {
        final colors = _palette().resolve(
          _scheme,
          selected: true,
          disabled: false,
        );
        expect(colors.background, _scheme.secondaryContainer);
        expect(colors.foreground, _scheme.onSecondaryContainer);
        expect(colors.border, isNull);
        expect(colors.elevation, 0);
      });

      test('tonal unselected uses the surface container', () {
        final colors = _palette().resolve(
          _scheme,
          selected: false,
          disabled: false,
        );
        expect(colors.background, _scheme.surfaceContainerHighest);
        expect(colors.foreground, _scheme.onSurface);
        expect(colors.border, isNull);
        expect(colors.elevation, 0);
      });

      test('outlined selected keeps the outline border', () {
        final colors = _palette(
          style: ButtonGroupStyle.outlined,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.background, _scheme.secondaryContainer);
        expect(colors.foreground, _scheme.onSecondaryContainer);
        expect(colors.border, _scheme.outline);
        expect(colors.elevation, 0);
      });

      test('outlined unselected is transparent with a border', () {
        final colors = _palette(
          style: ButtonGroupStyle.outlined,
        ).resolve(_scheme, selected: false, disabled: false);
        expect(colors.background, Colors.transparent);
        expect(colors.foreground, _scheme.onSurface);
        expect(colors.border, _scheme.outline);
        expect(colors.elevation, 0);
      });

      test('elevated selected raises the container', () {
        final colors = _palette(
          style: ButtonGroupStyle.elevated,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.background, _scheme.secondaryContainer);
        expect(colors.foreground, _scheme.onSecondaryContainer);
        expect(colors.border, isNull);
        expect(colors.elevation, 1);
      });

      test('elevated unselected uses the low surface container', () {
        final colors = _palette(
          style: ButtonGroupStyle.elevated,
        ).resolve(_scheme, selected: false, disabled: false);
        expect(colors.background, _scheme.surfaceContainerLow);
        expect(colors.foreground, _scheme.primary);
        expect(colors.border, isNull);
        expect(colors.elevation, 1);
      });
    });

    group('custom colors', () {
      const custom = Color(0xFF00696D);

      test('selectedColor replaces the selected background', () {
        final colors = _palette(
          selectedColor: custom,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.background, custom);
        expect(colors.foreground, ButtonGroupPalette.onColorFor(custom));
      });

      test('selectedColor leaves unselected buttons alone', () {
        final colors = _palette(
          selectedColor: custom,
        ).resolve(_scheme, selected: false, disabled: false);
        expect(colors.background, _scheme.surfaceContainerHighest);
        expect(colors.foreground, _scheme.onSurface);
      });

      test('unselectedColor replaces the unselected background', () {
        final colors = _palette(
          unselectedColor: custom,
        ).resolve(_scheme, selected: false, disabled: false);
        expect(colors.background, custom);
        expect(colors.foreground, ButtonGroupPalette.onColorFor(custom));
      });

      test('outlined custom colors become the border', () {
        final colors = _palette(
          style: ButtonGroupStyle.outlined,
          selectedColor: custom,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.border, custom);
      });

      test('non-outlined custom colors keep the style border', () {
        final colors = _palette(
          style: ButtonGroupStyle.filled,
          selectedColor: custom,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.border, _scheme.outline);
      });

      test('legacy color aliases selectedColor', () {
        final colors = _palette(
          legacyColor: Colors.red,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.background, Colors.red);
      });

      test('selectedColor takes precedence over legacy color', () {
        final colors = _palette(
          selectedColor: Colors.green,
          legacyColor: Colors.red,
        ).resolve(_scheme, selected: true, disabled: false);
        expect(colors.background, Colors.green);
      });
    });

    group('disabled state', () {
      test('dims the foreground and border', () {
        final colors = _palette().resolve(
          _scheme,
          selected: false,
          disabled: true,
        );
        expect(
          colors.foreground,
          _scheme.onSurface.withValues(alpha: 0.38),
        );
        expect(
          colors.border,
          _scheme.onSurface.withValues(alpha: 0.12),
        );
      });

      test('keeps the resolved custom background', () {
        const custom = Color(0xFF00696D);
        final colors = _palette(
          selectedColor: custom,
        ).resolve(_scheme, selected: true, disabled: true);
        expect(colors.background, custom);
      });

      test('keeps the style elevation', () {
        final colors = _palette(
          style: ButtonGroupStyle.elevated,
        ).resolve(_scheme, selected: false, disabled: true);
        expect(colors.elevation, 1);
      });
    });
  });
}
