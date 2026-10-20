import 'package:flutter/material.dart';

/// Sizes for the Expressive Split Button.
enum SplitButtonSize {
  xs,
  sm,
  md,
  lg,
  xl;

  double get height {
    switch (this) {
      case SplitButtonSize.xs:
        return 32.0;
      case SplitButtonSize.sm:
        return 40.0;
      case SplitButtonSize.md:
        return 56.0;
      case SplitButtonSize.lg:
        return 96.0;
      case SplitButtonSize.xl:
        return 136.0;
    }
  }

  double get trailingWidth {
    switch (this) {
      case SplitButtonSize.xs:
        return 22.0;
      case SplitButtonSize.sm:
        return 22.0;
      case SplitButtonSize.md:
        return 26.0;
      case SplitButtonSize.lg:
        return 38.0;
      case SplitButtonSize.xl:
        return 50.0;
    }
  }

  double get iconSize {
    switch (this) {
      case SplitButtonSize.xs:
        return 20.0;
      case SplitButtonSize.sm:
        return 24.0;
      case SplitButtonSize.md:
        return 24.0;
      case SplitButtonSize.lg:
        return 32.0;
      case SplitButtonSize.xl:
        return 40.0;
    }
  }

  double get innerCornerRadius {
    switch (this) {
      case SplitButtonSize.xs:
      case SplitButtonSize.sm:
      case SplitButtonSize.md:
        return 4.0;
      case SplitButtonSize.lg:
        return 8.0;
      case SplitButtonSize.xl:
        return 12.0;
    }
  }

  double get opticalChevronOffset {
    switch (this) {
      case SplitButtonSize.xs:
      case SplitButtonSize.sm:
        return -1.0;
      case SplitButtonSize.md:
        return -2.0;
      case SplitButtonSize.lg:
        return -3.0;
      case SplitButtonSize.xl:
        return -6.0;
    }
  }

  TextStyle? textStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (this) {
      case SplitButtonSize.xs:
        return textTheme.labelSmall;
      case SplitButtonSize.sm:
        return textTheme.labelMedium;
      case SplitButtonSize.md:
        return textTheme.labelLarge;
      case SplitButtonSize.lg:
        return textTheme.bodyLarge;
      case SplitButtonSize.xl:
        return textTheme.titleMedium;
    }
  }
}

/// Shapes for the Expressive Split Button.
enum SplitButtonShape { round, square }

/// Emphasis levels for the Expressive Split Button.
enum SplitButtonEmphasis { filled, tonal, elevated, outlined, text }

/// Alignment for the trailing segment's content.
enum SplitButtonTrailingAlignment { opticalCenter, geometricCenter }
