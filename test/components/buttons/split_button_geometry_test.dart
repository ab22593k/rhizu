import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/buttons/split_button_geometry.dart';
import 'package:rhizu/src/ui/components/buttons/split_button_tokens.dart';

const _scheme = ColorScheme.light();

void _expectCorners(
  BorderRadius actual,
  double tl,
  double tr,
  double bl,
  double br,
) {
  expect(
    actual,
    BorderRadius.only(
      topLeft: Radius.circular(tl),
      topRight: Radius.circular(tr),
      bottomLeft: Radius.circular(bl),
      bottomRight: Radius.circular(br),
    ),
  );
}

void main() {
  group('SplitButtonPalette', () {
    test('filled uses the primary container', () {
      final colors = const SplitButtonPalette(
        emphasis: SplitButtonEmphasis.filled,
      ).resolve(_scheme);
      expect(colors.background, _scheme.primary);
      expect(colors.foreground, _scheme.onPrimary);
      expect(colors.border, isNull);
      expect(colors.elevation, 0);
    });

    test('tonal uses the secondary container', () {
      final colors = const SplitButtonPalette(
        emphasis: SplitButtonEmphasis.tonal,
      ).resolve(_scheme);
      expect(colors.background, _scheme.secondaryContainer);
      expect(colors.foreground, _scheme.onSecondaryContainer);
      expect(colors.border, isNull);
      expect(colors.elevation, 0);
    });

    test('elevated uses the low surface container', () {
      final colors = const SplitButtonPalette(
        emphasis: SplitButtonEmphasis.elevated,
      ).resolve(_scheme);
      expect(colors.background, _scheme.surfaceContainerLow);
      expect(colors.foreground, _scheme.primary);
      expect(colors.border, isNull);
      expect(colors.elevation, 1);
    });

    test('outlined is transparent with an outline border', () {
      final colors = const SplitButtonPalette(
        emphasis: SplitButtonEmphasis.outlined,
      ).resolve(_scheme);
      expect(colors.background, Colors.transparent);
      expect(colors.foreground, _scheme.primary);
      expect(colors.border, _scheme.outline);
      expect(colors.elevation, 0);
    });

    test('text is transparent without a border', () {
      final colors = const SplitButtonPalette(
        emphasis: SplitButtonEmphasis.text,
      ).resolve(_scheme);
      expect(colors.background, Colors.transparent);
      expect(colors.foreground, _scheme.primary);
      expect(colors.border, isNull);
      expect(colors.elevation, 0);
    });
  });

  group('SplitButtonGeometry', () {
    group('tokens', () {
      test('exposes the size tokens', () {
        const geometry = SplitButtonGeometry(
          size: SplitButtonSize.md,
          shape: SplitButtonShape.round,
        );
        expect(geometry.height, 56);
        expect(geometry.innerRadius, 4);
      });

      test('leading padding follows the size', () {
        EdgeInsetsGeometry padding(SplitButtonSize size) => SplitButtonGeometry(
          size: size,
          shape: SplitButtonShape.round,
        ).leadingPadding();

        expect(
          padding(SplitButtonSize.xs),
          const EdgeInsets.fromLTRB(12, 0, 10, 0),
        );
        expect(
          padding(SplitButtonSize.sm),
          const EdgeInsets.fromLTRB(16, 0, 12, 0),
        );
        expect(
          padding(SplitButtonSize.md),
          const EdgeInsets.fromLTRB(24, 0, 24, 0),
        );
        expect(
          padding(SplitButtonSize.lg),
          const EdgeInsets.fromLTRB(48, 0, 48, 0),
        );
        expect(
          padding(SplitButtonSize.xl),
          const EdgeInsets.fromLTRB(64, 0, 64, 0),
        );
      });

      test('icon-label gap follows the size', () {
        double gap(SplitButtonSize size) => SplitButtonGeometry(
          size: size,
          shape: SplitButtonShape.round,
        ).iconLabelGap();

        expect(gap(SplitButtonSize.xs), 4);
        expect(gap(SplitButtonSize.sm), 8);
        expect(gap(SplitButtonSize.md), 8);
        expect(gap(SplitButtonSize.lg), 12);
        expect(gap(SplitButtonSize.xl), 16);
      });
    });

    group('morph eligibility', () {
      test('round M/L/XL buttons morph', () {
        for (final size in [
          SplitButtonSize.md,
          SplitButtonSize.lg,
          SplitButtonSize.xl,
        ]) {
          expect(
            SplitButtonGeometry(
              size: size,
              shape: SplitButtonShape.round,
            ).canMorph,
            isTrue,
          );
        }
      });

      test('round XS/S buttons do not morph', () {
        for (final size in [SplitButtonSize.xs, SplitButtonSize.sm]) {
          expect(
            SplitButtonGeometry(
              size: size,
              shape: SplitButtonShape.round,
            ).canMorph,
            isFalse,
          );
        }
      });

      test('square buttons never morph', () {
        expect(
          const SplitButtonGeometry(
            size: SplitButtonSize.md,
            shape: SplitButtonShape.square,
          ).canMorph,
          isFalse,
        );
      });

      test('morph progress is zero when morphing is disabled', () {
        const geometry = SplitButtonGeometry(
          size: SplitButtonSize.sm,
          shape: SplitButtonShape.round,
        );
        expect(geometry.morphProgress(0.7), 0);
      });

      test('morph progress passes through when morphing is enabled', () {
        const geometry = SplitButtonGeometry(
          size: SplitButtonSize.md,
          shape: SplitButtonShape.round,
        );
        expect(geometry.morphProgress(0.7), 0.7);
      });
    });

    group('trailing segment metrics', () {
      const geometry = SplitButtonGeometry(
        size: SplitButtonSize.md,
        shape: SplitButtonShape.round,
      );

      test('resting width is the size trailing width', () {
        expect(geometry.trailingWidthFor(0), 26);
      });

      test('width grows toward the full button height', () {
        expect(geometry.trailingWidthFor(0.5), 28);
        expect(geometry.trailingWidthFor(1), 56);
      });

      test('width never shrinks below the resting width', () {
        expect(geometry.trailingWidthFor(-0.5), 26);
      });

      test('horizontal padding centers the chevron while growing', () {
        expect(geometry.horizontalPaddingFor(0), 1);
        expect(geometry.horizontalPaddingFor(0.5), 0.5);
        expect(geometry.horizontalPaddingFor(1), 0);
      });

      test('small buttons keep zero horizontal padding', () {
        const small = SplitButtonGeometry(
          size: SplitButtonSize.sm,
          shape: SplitButtonShape.round,
        );
        expect(small.horizontalPaddingFor(1), 0);
      });

      test('inner radius grows to a circle', () {
        expect(geometry.morphInnerRadius(0), 4);
        expect(geometry.morphInnerRadius(0.5), 14);
        expect(geometry.morphInnerRadius(1), 28);
      });

      test('square buttons keep their inner radius', () {
        const square = SplitButtonGeometry(
          size: SplitButtonSize.md,
          shape: SplitButtonShape.square,
        );
        expect(square.morphInnerRadius(1), 4);
        expect(square.horizontalPaddingFor(1), 0);
      });
    });

    group('border radii', () {
      test('round leading segment has round outer corners', () {
        _expectCorners(
          const SplitButtonGeometry(
            size: SplitButtonSize.md,
            shape: SplitButtonShape.round,
          ).leadingBorderRadius(),
          28,
          4,
          28,
          4,
        );
      });

      test('square leading segment uses the inner radius', () {
        _expectCorners(
          const SplitButtonGeometry(
            size: SplitButtonSize.md,
            shape: SplitButtonShape.square,
          ).leadingBorderRadius(),
          4,
          4,
          4,
          4,
        );
      });

      test('round trailing segment morphs its inner corners', () {
        const geometry = SplitButtonGeometry(
          size: SplitButtonSize.md,
          shape: SplitButtonShape.round,
        );
        _expectCorners(geometry.trailingBorderRadius(0), 4, 28, 4, 28);
        _expectCorners(geometry.trailingBorderRadius(1), 28, 28, 28, 28);
      });

      test('square trailing segment uses the inner radius', () {
        _expectCorners(
          const SplitButtonGeometry(
            size: SplitButtonSize.md,
            shape: SplitButtonShape.square,
          ).trailingBorderRadius(1),
          4,
          4,
          4,
          4,
        );
      });
    });

    group('chevron offset', () {
      const geometry = SplitButtonGeometry(
        size: SplitButtonSize.md,
        shape: SplitButtonShape.round,
      );

      test('optical centering nudges the closed chevron', () {
        expect(
          geometry.chevronOffset(
            menuOpen: false,
            alignment: SplitButtonTrailingAlignment.opticalCenter,
          ),
          -2,
        );
      });

      test('optical centering is removed while open', () {
        expect(
          geometry.chevronOffset(
            menuOpen: true,
            alignment: SplitButtonTrailingAlignment.opticalCenter,
          ),
          0,
        );
      });

      test('geometric centering never nudges the chevron', () {
        expect(
          geometry.chevronOffset(
            menuOpen: false,
            alignment: SplitButtonTrailingAlignment.geometricCenter,
          ),
          0,
        );
      });
    });
  });
}
