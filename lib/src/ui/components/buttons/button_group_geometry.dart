import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:rhizu/src/ui/components/buttons/button_group_tokens.dart';

/// The four corner radii of one button in a `ButtonGroup`.
typedef ButtonGroupRadii = ({
  Radius tl,
  Radius tr,
  Radius bl,
  Radius br,
});

/// Pure layout math for the expressive button group.
///
/// Owns everything that can be derived from the group's configuration and
/// measured widths, independent of widget lifecycle. Keeping it separate
/// makes the press/selection morph and overflow behavior unit-testable.
class ButtonGroupGeometry {
  const ButtonGroupGeometry({
    required this.size,
    required this.variant,
    required this.shape,
    required this.direction,
    required this.textDirection,
    required this.itemCount,
    required this.expanded,
  });

  /// The pressed width multiplier (`pressed.item.width.multiplier`, 15%).
  static const double pressedWidthMultiplier = 0.15;

  /// Flex units per button at rest. Integer units (×1000) keep fractional 15%
  /// growth expressible without rounding every share to a whole unit.
  static const int flexBase = 1000;

  final ButtonGroupSize size;
  final ButtonGroupVariant variant;
  final ButtonGroupShape shape;
  final Axis direction;
  final TextDirection textDirection;
  final int itemCount;
  final bool expanded;

  bool get isVertical => direction == Axis.vertical;

  bool get isRtl => !isVertical && textDirection == TextDirection.rtl;

  /// Whether the group shares its available width between buttons.
  ///
  /// Connected groups always do; standard groups only when [expanded] is set.
  bool get isFlexible => variant == ButtonGroupVariant.connected || expanded;

  /// The gap between adjacent buttons.
  double get gap =>
      variant == ButtonGroupVariant.connected ? 2.0 : size.standardGap;

  /// The width reserved for the overflow menu button.
  double get overflowButtonWidth => size.iconSize + size.padding.horizontal;

  /// The width each button should take for the current press progress.
  ///
  /// Returns `null` for flexible groups (they allocate width through flex
  /// shares instead) and before the natural widths have been measured.
  double? widthFor({
    required int index,
    required double pressProgress,
    required int? pressedIndex,
    required List<double?> naturalWidths,
    required bool widthsMeasured,
  }) {
    // Flexible groups allocate width through flex shares, not explicit sizes.
    if (isFlexible) return null;
    if (!widthsMeasured || pressedIndex == null || pressProgress <= 0) {
      return null;
    }

    final natural = naturalWidths[index];
    if (natural == null) return null;

    if (index == pressedIndex) {
      return natural * (1 + pressedWidthMultiplier * pressProgress);
    }

    if ((index - pressedIndex).abs() == 1) {
      final neighborCount =
          (pressedIndex > 0 ? 1 : 0) + (pressedIndex < itemCount - 1 ? 1 : 0);
      if (neighborCount == 0) return natural;

      final pressedNatural = naturalWidths[pressedIndex];
      if (pressedNatural == null) return natural;

      final growth = pressedNatural * pressedWidthMultiplier * pressProgress;
      final shrink = growth / neighborCount;
      // Never shrink a neighbor by more than 10% so its content stays legible.
      final clampedShrink = math.min(shrink, natural * 0.10);
      return natural - clampedShrink;
    }

    return natural;
  }

  /// The flex share each button takes in a flexible (expanded) group.
  ///
  /// At rest every button gets an equal share. While pressed, a standard
  /// group's pressed button grows by 15% and its neighbors give up exactly
  /// that share, keeping the total (and therefore the group width) stable.
  /// Connected groups never morph width on press.
  int flexFor({
    required int index,
    required double pressProgress,
    required int? pressedIndex,
  }) {
    if (variant == ButtonGroupVariant.connected) return flexBase;
    if (pressedIndex == null || pressProgress <= 0) return flexBase;

    if (index == pressedIndex) {
      return (flexBase * (1 + pressedWidthMultiplier * pressProgress)).round();
    }

    if ((index - pressedIndex).abs() == 1) {
      final neighborCount =
          (pressedIndex > 0 ? 1 : 0) + (pressedIndex < itemCount - 1 ? 1 : 0);
      if (neighborCount == 0) return flexBase;

      return math.max(
        (flexBase *
                (1 - (pressedWidthMultiplier * pressProgress) / neighborCount))
            .round(),
        100,
      );
    }

    return flexBase;
  }

  /// The four corner radii for the button at [index].
  ///
  /// [pressProgress] comes from the fast spatial spring (0 = rest, 1 =
  /// pressed) and [selectionMorph] from the 200ms selection tween (0 =
  /// unselected, 1 = selected).
  ButtonGroupRadii radiiFor({
    required int index,
    required double pressProgress,
    required double selectionMorph,
  }) {
    final height = size.height;
    final pill = height / 2;
    final restInner = size.innerCorner;
    final pressedInner = size.pressedInnerCorner;
    final selectedInner = height * 0.5; // `selected.inner-corner = 50%`
    final squareOuter = size.innerCorner;
    final first = index == 0;
    final last = index == itemCount - 1;

    // The inner-facing corner value combines the press morph and the
    // selection morph (selection dominates).
    final inner = _lerp(
      _lerp(restInner, pressedInner, pressProgress),
      selectedInner,
      selectionMorph,
    );

    final double leading;
    final double trailing;
    if (variant == ButtonGroupVariant.standard) {
      final rest = shape == ButtonGroupShape.round ? pill : squareOuter;
      // The selected button swaps between round and square; otherwise the
      // inner-facing corners flatten slightly while pressed.
      if (selectionMorph > 0) {
        final swapped = shape == ButtonGroupShape.round ? squareOuter : pill;
        leading = _lerp(rest, swapped, selectionMorph);
        trailing = leading;
      } else {
        leading = first ? rest : _lerp(rest, pressedInner, pressProgress);
        trailing = last ? rest : _lerp(rest, pressedInner, pressProgress);
      }
    } else {
      final outer = shape == ButtonGroupShape.round ? pill : squareOuter;
      leading = first ? outer : inner;
      trailing = last ? outer : inner;
    }

    if (isVertical) {
      return (
        tl: Radius.circular(leading),
        tr: Radius.circular(leading),
        bl: Radius.circular(trailing),
        br: Radius.circular(trailing),
      );
    }
    if (isRtl) {
      return (
        tl: Radius.circular(trailing),
        tr: Radius.circular(leading),
        bl: Radius.circular(trailing),
        br: Radius.circular(leading),
      );
    }
    return (
      tl: Radius.circular(leading),
      tr: Radius.circular(trailing),
      bl: Radius.circular(leading),
      br: Radius.circular(trailing),
    );
  }

  /// The corner radii for the overflow menu button, which sits at the end of
  /// the group and inherits the group's outer corner on the trailing edge.
  ButtonGroupRadii overflowRadii() {
    final height = size.height;
    final pill = height / 2;
    final inner = size.innerCorner;
    final rest = shape == ButtonGroupShape.round ? pill : inner;

    // Standard items rest with the outer shape on every corner; connected
    // items face the group with their inner corner.
    final (leading, trailing) = variant == ButtonGroupVariant.standard
        ? (rest, rest)
        : (inner, rest);

    if (isVertical) {
      return (
        tl: Radius.circular(leading),
        tr: Radius.circular(leading),
        bl: Radius.circular(trailing),
        br: Radius.circular(trailing),
      );
    }
    if (isRtl) {
      return (
        tl: Radius.circular(trailing),
        tr: Radius.circular(leading),
        bl: Radius.circular(trailing),
        br: Radius.circular(leading),
      );
    }
    return (
      tl: Radius.circular(leading),
      tr: Radius.circular(trailing),
      bl: Radius.circular(leading),
      br: Radius.circular(trailing),
    );
  }

  /// The number of leading items that fit in [availableWidth] next to the
  /// overflow menu button, or `null` when every item fits on its own (no
  /// overflow needed).
  ///
  /// [widths] must contain the natural width of every item, in order.
  static int? overflowFitCount({
    required List<double> widths,
    required double availableWidth,
    required double gap,
    required double overflowWidth,
  }) {
    if (widths.length <= 1) return null;

    // Everything fits without the overflow button?
    var all = 0.0;
    for (var i = 0; i < widths.length; i++) {
      all += widths[i] + (i > 0 ? gap : 0);
    }
    if (all <= availableWidth) return null;

    // Greedily fit leading items; every item carries a trailing gap and the
    // overflow button sits at the end.
    var count = 0;
    var used = 0.0;
    for (var i = 0; i < widths.length; i++) {
      final next = used + widths[i] + gap + overflowWidth;
      if (next > availableWidth) break;
      used += widths[i] + gap;
      count++;
    }

    // When nothing fits next to the overflow button, collapse every button
    // into the menu and show the overflow button on its own.
    return count.clamp(0, widths.length - 1);
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
