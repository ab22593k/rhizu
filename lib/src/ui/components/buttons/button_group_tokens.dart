import 'package:flutter/material.dart';

/// The variants of the expressive `ButtonGroup`.
///
/// Mirrors the M3 Expressive button group spec:
/// - [ButtonGroupVariant.standard] adds interaction between adjacent buttons.
///   Pressing or selecting a button grows its width by 15% (animated with the
///   fast spatial spring) and the buttons directly next to it temporarily
///   give up that width.
/// - [ButtonGroupVariant.connected] visually joins the buttons with a 2dp
///   gutter and only changes the shape of the pressed or selected button.
///   It is the expressive replacement for the M3 segmented button.
enum ButtonGroupVariant { standard, connected }

/// The sizes of the expressive `ButtonGroup`.
///
/// Container heights follow the M3 Expressive button group tokens
/// (`md.comp.button-group.*.container.height`): XS 32dp, S 40dp, M 56dp,
/// L 96dp, XL 136dp.
enum ButtonGroupSize {
  xs,
  sm,
  md,
  lg,
  xl;

  /// The container height for this size.
  double get height => switch (this) {
    ButtonGroupSize.xs => 32.0,
    ButtonGroupSize.sm => 40.0,
    ButtonGroupSize.md => 56.0,
    ButtonGroupSize.lg => 96.0,
    ButtonGroupSize.xl => 136.0,
  };

  /// The gap between buttons in a [ButtonGroupVariant.standard] group
  /// (`md.comp.button-group.standard.*.between-space`).
  double get standardGap => switch (this) {
    ButtonGroupSize.xs => 18.0,
    ButtonGroupSize.sm => 12.0,
    ButtonGroupSize.md || ButtonGroupSize.lg || ButtonGroupSize.xl => 8.0,
  };

  /// The resting inner corner radius of the buttons.
  ///
  /// For [ButtonGroupVariant.connected] this is the inner-corner token
  /// (`md.comp.button-group.connected.*.inner-corner.corner-size`). For the
  /// square shape it is also the outer corner radius
  /// (`md.comp.button-group.connected.*.container.shape`).
  double get innerCorner => switch (this) {
    ButtonGroupSize.xs => 4.0,
    ButtonGroupSize.sm || ButtonGroupSize.md => 8.0,
    ButtonGroupSize.lg => 16.0,
    ButtonGroupSize.xl => 20.0,
  };

  /// The inner corner radius while a connected button is pressed
  /// (`md.comp.button-group.connected.*.pressed.inner-corner.corner-size`).
  double get pressedInnerCorner => switch (this) {
    ButtonGroupSize.xs || ButtonGroupSize.sm || ButtonGroupSize.md => 4.0,
    ButtonGroupSize.lg => 12.0,
    ButtonGroupSize.xl => 16.0,
  };

  /// The icon size for this size.
  double get iconSize => switch (this) {
    ButtonGroupSize.xs => 20.0,
    ButtonGroupSize.sm || ButtonGroupSize.md => 24.0,
    ButtonGroupSize.lg => 32.0,
    ButtonGroupSize.xl => 40.0,
  };

  /// The horizontal padding of each button.
  EdgeInsetsGeometry get padding => switch (this) {
    ButtonGroupSize.xs ||
    ButtonGroupSize.sm => const EdgeInsets.symmetric(horizontal: 12),
    ButtonGroupSize.md => const EdgeInsets.symmetric(horizontal: 16),
    ButtonGroupSize.lg => const EdgeInsets.symmetric(horizontal: 24),
    ButtonGroupSize.xl => const EdgeInsets.symmetric(horizontal: 32),
  };

  /// The label text style for this size.
  TextStyle? textStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return switch (this) {
      ButtonGroupSize.xs => textTheme.labelSmall,
      ButtonGroupSize.sm => textTheme.labelMedium,
      ButtonGroupSize.md => textTheme.labelLarge,
      ButtonGroupSize.lg => textTheme.bodyLarge,
      ButtonGroupSize.xl => textTheme.titleMedium,
    };
  }
}

/// The shapes of the expressive `ButtonGroup`.
enum ButtonGroupShape {
  /// Fully rounded (pill) outer corners.
  round,

  /// Minimal corner radius on the outer corners.
  square,
}

/// The color style of the expressive `ButtonGroup`.
///
/// Button groups have no color properties of their own; they reuse the button
/// color roles. The selected container always uses the toggle (segmented)
/// color roles unless [ButtonGroupStyle.filled] is chosen.
enum ButtonGroupStyle {
  /// Filled container emphasis. Selected buttons use the primary container.
  filled,

  /// Tonal container emphasis. Selected buttons use the secondary container.
  tonal,

  /// Outlined treatment with a 1dp outline border.
  outlined,

  /// Elevated treatment with a subtle shadow.
  elevated,
}

/// The overflow behavior of a `ButtonGroup` when it cannot fit its available
/// width.
enum ButtonGroupOverflowMode {
  /// Buttons always render in the group; a fixed group may exceed the
  /// available width.
  none,

  /// When the available width cannot fit every button, the trailing buttons
  /// collapse into an overflow menu button (⋯). Only horizontal, fixed
  /// (non-expanded) [ButtonGroupVariant.standard] groups support this;
  /// connected, expanded, and vertical groups ignore it because their buttons
  /// always fit by sharing the width.
  menu,
}
