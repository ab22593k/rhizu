import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/buttons/split_button_tokens.dart';

/// The resolved container colors for one split-button emphasis.
typedef SplitButtonColors = ({
  Color background,
  Color foreground,
  Color? border,
  double elevation,
});

/// Resolves split-button colors from the active [ColorScheme].
class SplitButtonPalette {
  const SplitButtonPalette({required this.emphasis});

  final SplitButtonEmphasis emphasis;

  /// Resolves the container, foreground, border, and elevation for [emphasis].
  SplitButtonColors resolve(ColorScheme colorScheme) {
    return switch (emphasis) {
      SplitButtonEmphasis.filled => (
        background: colorScheme.primary,
        foreground: colorScheme.onPrimary,
        border: null,
        elevation: 0,
      ),
      SplitButtonEmphasis.tonal => (
        background: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
        border: null,
        elevation: 0,
      ),
      SplitButtonEmphasis.elevated => (
        background: colorScheme.surfaceContainerLow,
        foreground: colorScheme.primary,
        border: null,
        elevation: 1,
      ),
      SplitButtonEmphasis.outlined => (
        background: Colors.transparent,
        foreground: colorScheme.primary,
        border: colorScheme.outline,
        elevation: 0,
      ),
      SplitButtonEmphasis.text => (
        background: Colors.transparent,
        foreground: colorScheme.primary,
        border: null,
        elevation: 0,
      ),
    };
  }
}

/// Pure layout math for the split button and its trailing-segment morph.
class SplitButtonGeometry {
  const SplitButtonGeometry({required this.size, required this.shape});

  /// The minimum touch target for the trailing segment.
  static const double minimumTrailingWidth = 48;

  final SplitButtonSize size;
  final SplitButtonShape shape;

  double get height => size.height;

  double get innerRadius => size.innerCornerRadius;

  bool get isRound => shape == SplitButtonShape.round;

  /// Whether the trailing segment grows into a circle when the menu opens.
  ///
  /// Only round M/L/XL buttons morph; XS and S stay at their fixed width.
  bool get canMorph =>
      isRound &&
      (size == SplitButtonSize.md ||
          size == SplitButtonSize.lg ||
          size == SplitButtonSize.xl);

  /// The effective morph progress, clamped to zero when morphing is disabled.
  double morphProgress(double animationValue) => canMorph ? animationValue : 0;

  /// The trailing segment width for [morphProgress].
  ///
  /// The segment grows from its resting width to the full button height so it
  /// becomes a circle when the menu is fully open.
  double trailingWidthFor(double morphProgress) =>
      math.max(size.trailingWidth, height * morphProgress);

  /// The horizontal padding that centers the chevron while the segment grows.
  double horizontalPaddingFor(double morphProgress) => canMorph
      ? (1 - morphProgress) * (size.trailingWidth - size.iconSize) / 2
      : 0;

  /// The inner corner radius for the trailing segment at [morphProgress].
  double morphInnerRadius(double morphProgress) => canMorph
      ? math.max(innerRadius, (height / 2) * morphProgress)
      : innerRadius;

  /// The leading segment's corner radii: round outer edge, square inner edge.
  BorderRadius leadingBorderRadius() => BorderRadius.only(
    topLeft: Radius.circular(isRound ? height / 2 : innerRadius),
    bottomLeft: Radius.circular(isRound ? height / 2 : innerRadius),
    topRight: Radius.circular(innerRadius),
    bottomRight: Radius.circular(innerRadius),
  );

  /// The trailing segment's corner radii at [morphProgress].
  BorderRadius trailingBorderRadius(double morphProgress) => BorderRadius.only(
    topLeft: Radius.circular(morphInnerRadius(morphProgress)),
    bottomLeft: Radius.circular(morphInnerRadius(morphProgress)),
    topRight: Radius.circular(isRound ? height / 2 : innerRadius),
    bottomRight: Radius.circular(isRound ? height / 2 : innerRadius),
  );

  /// The chevron's optical offset.
  ///
  /// Optical centering nudges the chevron toward the visual center of the
  /// segment; the offset is removed while the menu is open.
  double chevronOffset({
    required bool menuOpen,
    required SplitButtonTrailingAlignment alignment,
  }) {
    return alignment == SplitButtonTrailingAlignment.opticalCenter && !menuOpen
        ? size.opticalChevronOffset
        : 0;
  }

  /// The leading segment's horizontal padding.
  EdgeInsetsGeometry leadingPadding() => switch (size) {
    SplitButtonSize.xs => const EdgeInsets.fromLTRB(12, 0, 10, 0),
    SplitButtonSize.sm => const EdgeInsets.fromLTRB(16, 0, 12, 0),
    SplitButtonSize.md => const EdgeInsets.fromLTRB(24, 0, 24, 0),
    SplitButtonSize.lg => const EdgeInsets.fromLTRB(48, 0, 48, 0),
    SplitButtonSize.xl => const EdgeInsets.fromLTRB(64, 0, 64, 0),
  };

  /// The gap between the leading icon and the label.
  double iconLabelGap() => switch (size) {
    SplitButtonSize.xs => 4,
    SplitButtonSize.sm || SplitButtonSize.md => 8,
    SplitButtonSize.lg => 12,
    SplitButtonSize.xl => 16,
  };
}
