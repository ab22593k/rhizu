import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/buttons/button_group_tokens.dart';

/// The resolved colors for one button state.
typedef ButtonGroupColors = ({
  Color background,
  Color foreground,
  Color? border,
  double elevation,
});

/// Resolves button-group container colors from the active color scheme and
/// the group's custom-color overrides.
class ButtonGroupPalette {
  const ButtonGroupPalette({
    required this.style,
    this.selectedColor,
    this.unselectedColor,
    this.legacyColor,
  });

  final ButtonGroupStyle style;
  final Color? selectedColor;
  final Color? unselectedColor;

  /// The deprecated `color` parameter, which aliases [selectedColor].
  final Color? legacyColor;

  /// Resolves the visual properties for a button in [selected]/[disabled]
  /// state.
  ButtonGroupColors resolve(
    ColorScheme colorScheme, {
    required bool selected,
    required bool disabled,
  }) {
    final (background, foreground, border, elevation) = switch (style) {
      ButtonGroupStyle.filled when selected => (
        colorScheme.primary,
        colorScheme.onPrimary,
        colorScheme.outline as Color?,
        0.0,
      ),
      ButtonGroupStyle.filled => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
        colorScheme.outline as Color?,
        0.0,
      ),
      ButtonGroupStyle.tonal when selected => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        null,
        0.0,
      ),
      ButtonGroupStyle.tonal => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
        null,
        0.0,
      ),
      ButtonGroupStyle.outlined when selected => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        colorScheme.outline as Color?,
        0.0,
      ),
      ButtonGroupStyle.outlined => (
        Colors.transparent,
        colorScheme.onSurface,
        colorScheme.outline as Color?,
        0.0,
      ),
      ButtonGroupStyle.elevated when selected => (
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
        null,
        1.0,
      ),
      ButtonGroupStyle.elevated => (
        colorScheme.surfaceContainerLow,
        colorScheme.primary,
        null,
        1.0,
      ),
    };

    // Custom color overrides replace the container color of their state and
    // derive a readable foreground (and an outlined border) from it.
    final custom = selected ? (selectedColor ?? legacyColor) : unselectedColor;
    final resolvedBackground = custom ?? background;
    final resolvedForeground = custom != null ? onColorFor(custom) : foreground;
    final resolvedBorder = custom != null
        ? (style == ButtonGroupStyle.outlined ? custom : border)
        : border;

    if (disabled) {
      return (
        background: resolvedBackground,
        foreground: colorScheme.onSurface.withValues(alpha: 0.38),
        border: colorScheme.onSurface.withValues(alpha: 0.12),
        elevation: elevation,
      );
    }

    return (
      background: resolvedBackground,
      foreground: resolvedForeground,
      border: resolvedBorder,
      elevation: elevation,
    );
  }

  /// The WCAG relative-luminance contrast ratio between two colors.
  static double contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// The foreground color that reads best on [background]: black or white,
  /// whichever has the higher WCAG contrast ratio.
  static Color onColorFor(Color background) {
    final white = contrastRatio(background, Colors.white);
    final black = contrastRatio(background, Colors.black);
    return white >= black ? Colors.white : Colors.black;
  }
}
