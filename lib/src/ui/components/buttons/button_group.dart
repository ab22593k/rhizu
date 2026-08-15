import 'dart:math' as math;

import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/components/indicators/animation/spring_curve.dart';
import 'package:rhizu/src/ui/styles/motion/tokens.dart';

/// The variants of the expressive [ButtonGroup].
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

/// The sizes of the expressive [ButtonGroup].
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
  double get height {
    switch (this) {
      case ButtonGroupSize.xs:
        return 32.0;
      case ButtonGroupSize.sm:
        return 40.0;
      case ButtonGroupSize.md:
        return 56.0;
      case ButtonGroupSize.lg:
        return 96.0;
      case ButtonGroupSize.xl:
        return 136.0;
    }
  }

  /// The gap between buttons in a [ButtonGroupVariant.standard] group
  /// (`md.comp.button-group.standard.*.between-space`).
  double get standardGap {
    switch (this) {
      case ButtonGroupSize.xs:
        return 18.0;
      case ButtonGroupSize.sm:
        return 12.0;
      case ButtonGroupSize.md:
      case ButtonGroupSize.lg:
      case ButtonGroupSize.xl:
        return 8.0;
    }
  }

  /// The resting inner corner radius of the buttons.
  ///
  /// For [ButtonGroupVariant.connected] this is the inner-corner token
  /// (`md.comp.button-group.connected.*.inner-corner.corner-size`). For the
  /// square shape it is also the outer corner radius
  /// (`md.comp.button-group.connected.*.container.shape`).
  double get innerCorner {
    switch (this) {
      case ButtonGroupSize.xs:
        return 4.0;
      case ButtonGroupSize.sm:
      case ButtonGroupSize.md:
        return 8.0;
      case ButtonGroupSize.lg:
        return 16.0;
      case ButtonGroupSize.xl:
        return 20.0;
    }
  }

  /// The inner corner radius while a connected button is pressed
  /// (`md.comp.button-group.connected.*.pressed.inner-corner.corner-size`).
  double get pressedInnerCorner {
    switch (this) {
      case ButtonGroupSize.xs:
      case ButtonGroupSize.sm:
      case ButtonGroupSize.md:
        return 4.0;
      case ButtonGroupSize.lg:
        return 12.0;
      case ButtonGroupSize.xl:
        return 16.0;
    }
  }

  /// The icon size for this size.
  double get iconSize {
    switch (this) {
      case ButtonGroupSize.xs:
        return 20.0;
      case ButtonGroupSize.sm:
      case ButtonGroupSize.md:
        return 24.0;
      case ButtonGroupSize.lg:
        return 32.0;
      case ButtonGroupSize.xl:
        return 40.0;
    }
  }

  /// The horizontal padding of each button.
  EdgeInsetsGeometry get padding {
    switch (this) {
      case ButtonGroupSize.xs:
      case ButtonGroupSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12);
      case ButtonGroupSize.md:
        return const EdgeInsets.symmetric(horizontal: 16);
      case ButtonGroupSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24);
      case ButtonGroupSize.xl:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  /// The label text style for this size.
  TextStyle? textStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (this) {
      case ButtonGroupSize.xs:
        return textTheme.labelSmall;
      case ButtonGroupSize.sm:
        return textTheme.labelMedium;
      case ButtonGroupSize.md:
        return textTheme.labelLarge;
      case ButtonGroupSize.lg:
        return textTheme.bodyLarge;
      case ButtonGroupSize.xl:
        return textTheme.titleMedium;
    }
  }
}

/// The shapes of the expressive [ButtonGroup].
enum ButtonGroupShape {
  /// Fully rounded (pill) outer corners.
  round,

  /// Minimal corner radius on the outer corners.
  square,
}

/// The color style of the expressive [ButtonGroup].
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

/// The overflow behavior of a [ButtonGroup] when it cannot fit its available
/// width.
enum ButtonGroupOverflowMode {
  /// Buttons always render in the group; a fixed group may exceed the
  /// available width.
  none,

  /// When the available width cannot fit every button, the trailing buttons
  /// collapse into an overflow menu button (⋯). Only horizontal, fixed
  /// (non-[ButtonGroup.expanded]) [ButtonGroupVariant.standard] groups
  /// support this; connected, expanded, and vertical groups ignore it
  /// because their buttons always fit by sharing the width.
  menu,
}

/// A single item of a [ButtonGroup].
class ButtonGroupItem<T> {
  const ButtonGroupItem({
    required this.value,
    this.icon,
    this.label,
    this.tooltip,
    this.enabled = true,
  });

  /// The value that identifies this item in the selection set.
  final T value;

  /// The leading icon, shown before [label] (optional).
  final IconData? icon;

  /// The label text (optional for icon-only segments).
  final String? label;

  /// A tooltip describing the item. Recommended for icon-only items.
  final String? tooltip;

  /// Whether the item is interactive. Disabled items cannot be selected.
  final bool enabled;
}

/// The M3 Expressive button group.
///
/// Button groups organize buttons and add interactions between them. Two
/// variants are supported, matching the M3 Expressive button group spec:
///
/// - **[ButtonGroupVariant.standard]** – an invisible container that adds
///   padding between independent buttons. Pressing or selecting a button
///   changes its width (a 15% growth animated with the fast spatial spring)
///   and the buttons directly next to it temporarily give up that width.
///   By default standard groups hug the width of their buttons; pass
///   [ButtonGroup.expanded] to make them share the available width instead.
/// - **[ButtonGroupVariant.connected]** – the buttons are visually joined
///   with a 2dp gutter and always share the available width. Only the
///   pressed or selected button changes shape (its inner corners morph).
///   This variant replaces the M3 segmented button, which is no longer
///   recommended.
///
/// Selection mirrors the segmented button API: pass the current selection via
/// [selected] and react to changes with [onSelectionChanged]. Use
/// [multiSelectionEnabled] for multi-select and [emptySelectionAllowed] to
/// allow deselecting the last item. On narrow windows, set
/// [ButtonGroup.overflowMode] to collapse trailing buttons into a menu.
///
/// See also:
/// * [M3 Expressive button groups](https://m3.material.io/components/button-groups/overview)
class ButtonGroup<T> extends StatefulWidget {
  /// Creates an expressive button group.
  const ButtonGroup({
    required this.items,
    required this.selected,
    super.key,
    this.onSelectionChanged,
    this.variant = ButtonGroupVariant.standard,
    this.size = ButtonGroupSize.md,
    this.shape = ButtonGroupShape.round,
    this.style = ButtonGroupStyle.tonal,
    // Kept for backward compatibility with the original custom-color API;
    // it is a fresh deprecation, not one awaiting a breaking release.
    // ignore: remove_deprecations_in_breaking_versions
    @Deprecated(
      'Use selectedColor instead. This parameter will be removed in a '
      'future release.',
    )
    this.color,
    this.selectedColor,
    this.unselectedColor,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.direction = Axis.horizontal,
    this.expanded = false,
    this.overflowMode = ButtonGroupOverflowMode.none,
    this.showSelectedIcon = false,
    this.selectedIcon,
  }) : assert(
         items.length > 0,
         'ButtonGroup requires at least one item.',
       );

  /// The items displayed in the group, in order.
  final List<ButtonGroupItem<T>> items;

  /// The currently selected values.
  ///
  /// The widget is controlled: update this set (usually from
  /// [onSelectionChanged]) to change the selection.
  final Set<T> selected;

  /// Called when the selection changes.
  ///
  /// When `null`, items are read-only and cannot be selected.
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// The variant: [ButtonGroupVariant.standard] or
  /// [ButtonGroupVariant.connected].
  final ButtonGroupVariant variant;

  /// The size: XS, S, M, L, or XL.
  final ButtonGroupSize size;

  /// The shape: [ButtonGroupShape.round] (pill) or
  /// [ButtonGroupShape.square].
  final ButtonGroupShape shape;

  /// The color style of the group.
  final ButtonGroupStyle style;

  /// A custom container color for selected buttons.
  ///
  /// Overrides the selected-state background that [ButtonGroupStyle] would
  /// otherwise provide, across all styles. The foreground (icon/label/check)
  /// is derived automatically from this color — black or white, whichever
  /// has the higher WCAG contrast ratio — so the selection stays readable.
  /// Unselected buttons keep the style's default neutral treatment unless
  /// [unselectedColor] is set.
  final Color? selectedColor;

  /// A custom container color for unselected buttons.
  ///
  /// Overrides the resting background that [ButtonGroupStyle] would
  /// otherwise provide. Like [selectedColor], the foreground is derived
  /// automatically for readable contrast, and for the outlined style the
  /// border picks up this color.
  final Color? unselectedColor;

  /// Deprecated: use [selectedColor] instead.
  // Kept for backward compatibility with the original custom-color API;
  // it is a fresh deprecation, not one awaiting a breaking release.
  // ignore: remove_deprecations_in_breaking_versions
  @Deprecated(
    'Use selectedColor instead. This parameter will be removed in a future '
    'release.',
  )
  final Color? color;

  /// Whether multiple items can be selected at once.
  final bool multiSelectionEnabled;

  /// Whether the selection can be emptied (deselect the last selected item).
  final bool emptySelectionAllowed;

  /// The layout direction of the group.
  final Axis direction;

  /// Whether the buttons share the available width (flexible resizing).
  ///
  /// Per the M3 Expressive guideline, button groups can be **fixed** or
  /// **flexible**: flexible groups automatically grow or shrink the width of
  /// their buttons to fill the space they are placed in, until every button
  /// is at its widest. This only affects [ButtonGroupVariant.standard]
  /// groups — connected groups always span the width of their surface.
  ///
  /// When `true`, horizontal standard groups fill the available width and
  /// give every button an equal share; vertical groups stretch each button
  /// to the full width. The 15% pressed-width morph still applies: the
  /// pressed button takes a larger share and its neighbors give it up.
  final bool expanded;

  /// How the group behaves when it does not fit its available width.
  ///
  /// With [ButtonGroupOverflowMode.menu], horizontal fixed standard groups
  /// collapse their trailing buttons into an overflow menu button (⋯) on
  /// narrow windows; the collapsed items stay selectable from the menu.
  /// See [ButtonGroupOverflowMode] for which groups support overflow.
  final ButtonGroupOverflowMode overflowMode;

  /// Whether to show a check icon on selected items.
  ///
  /// Defaults to `false`: the expressive spec communicates selection through
  /// shape and color morphing. Set to `true` to also show a check.
  final bool showSelectedIcon;

  /// Custom icon shown on selected items when [showSelectedIcon] is `true`.
  final Widget? selectedIcon;

  @override
  State<ButtonGroup<T>> createState() => _ButtonGroupState<T>();
}

class _ButtonGroupState<T> extends State<ButtonGroup<T>>
    with SingleTickerProviderStateMixin {
  late final List<GlobalKey> _itemKeys;
  late List<double?> _naturalWidths;
  bool _widthsMeasured = false;

  int? _pressedIndex;
  late final AnimationController _pressController;
  late final Animation<double> _pressAnimation;

  /// The pressed width multiplier (`pressed.item.width.multiplier`, 15%).
  static const double _pressedWidthMultiplier = 0.15;

  /// Selection morph duration: 200ms per the expressive motion spec.
  static const Duration _selectionMorphDuration = Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
    _naturalWidths = List<double?>.filled(widget.items.length, null);
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pressAnimation = _pressController.drive(
      CurveTween(
        curve: SpringCurve(description: MotionTokens.expressiveFastSpatial),
      ),
    );
    _scheduleMeasurement();
  }

  @override
  void didUpdateWidget(covariant ButtonGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _itemKeys
        ..clear()
        ..addAll(List.generate(widget.items.length, (_) => GlobalKey()));
      _naturalWidths = List<double?>.filled(widget.items.length, null);
      _widthsMeasured = false;
      _scheduleMeasurement();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  /// Measures the natural width of every button after the first layout so the
  /// standard variant can grow a pressed button by 15% while its neighbors
  /// give up exactly that width (keeping the container width stable).
  void _scheduleMeasurement() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      var changed = false;
      for (var i = 0; i < _itemKeys.length; i++) {
        final renderObject = _itemKeys[i].currentContext?.findRenderObject();
        final width = (renderObject as RenderBox?)?.size.width;
        if (width != null && width > 0 && width != _naturalWidths[i]) {
          _naturalWidths[i] = width;
          changed = true;
        }
      }
      if (changed) {
        setState(() => _widthsMeasured = true);
      }
    });
  }

  void _handleTap(int index) {
    final item = widget.items[index];
    if (!item.enabled || widget.onSelectionChanged == null) return;
    final wasSelected = widget.selected.contains(item.value);
    final next = Set<T>.from(widget.selected);
    if (wasSelected) {
      if (widget.emptySelectionAllowed) next.remove(item.value);
    } else if (widget.multiSelectionEnabled) {
      next.add(item.value);
    } else {
      next
        ..clear()
        ..add(item.value);
    }
    if (!setEquals(next, widget.selected)) {
      widget.onSelectionChanged!(next);
    }
  }

  void _handlePressStart(int index) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    setState(() => _pressedIndex = index);
    if (reduceMotion) {
      _pressController.value = 1;
    } else {
      _pressController.forward(from: 0);
    }
  }

  void _handlePressEnd() {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    setState(() => _pressedIndex = null);
    if (reduceMotion) {
      _pressController.value = 0;
    } else {
      _pressController.reverse();
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Whether the group uses flexible (share-the-width) layout: connected
  /// groups always do; standard groups only when [ButtonGroup.expanded] is
  /// set.
  bool get _flexible =>
      widget.variant == ButtonGroupVariant.connected || widget.expanded;

  /// The width each button should take for the current press progress.
  ///
  /// Returns `null` for flexible groups (they allocate width through flex
  /// shares instead) and before the natural widths have been measured.
  double? _widthFor(int index, double pressProgress) {
    // Flexible groups allocate width through flex shares, not explicit sizes.
    if (_flexible) return null;
    final pressed = _pressedIndex;
    if (!_widthsMeasured || pressed == null || pressProgress <= 0) return null;
    final natural = _naturalWidths[index];
    if (natural == null) return null;

    if (index == pressed) {
      return natural * (1 + _pressedWidthMultiplier * pressProgress);
    }
    if ((index - pressed).abs() == 1) {
      final neighborCount =
          (pressed > 0 ? 1 : 0) + (pressed < widget.items.length - 1 ? 1 : 0);
      if (neighborCount == 0) return natural;
      final growth =
          _naturalWidths[pressed]! * _pressedWidthMultiplier * pressProgress;
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
  /// Connected groups never morph width on press. Shares are scaled to
  /// integer flex units (×1000) so fractional 15% growth stays expressible.
  int _flexFor(int index, double pressProgress) {
    if (widget.variant == ButtonGroupVariant.connected) return 1000;
    final pressed = _pressedIndex;
    if (pressed == null || pressProgress <= 0) return 1000;
    if (index == pressed) {
      return (1000 * (1 + _pressedWidthMultiplier * pressProgress)).round();
    }
    if ((index - pressed).abs() == 1) {
      final neighborCount =
          (pressed > 0 ? 1 : 0) + (pressed < widget.items.length - 1 ? 1 : 0);
      if (neighborCount == 0) return 1000;
      return math.max(
        (1000 * (1 - (_pressedWidthMultiplier * pressProgress) / neighborCount))
            .round(),
        100,
      );
    }
    return 1000;
  }

  /// The four corner radii for the button at [index].
  ///
  /// [pressProgress] comes from the fast spatial spring (0 = rest, 1 =
  /// pressed) and [selectionMorph] from the 200ms selection tween (0 =
  /// unselected, 1 = selected).
  ({Radius tl, Radius tr, Radius bl, Radius br}) _radiiFor(
    int index,
    double pressProgress,
    double selectionMorph,
  ) {
    final height = widget.size.height;
    final pill = height / 2;
    final restInner = widget.size.innerCorner;
    final pressedInner = widget.size.pressedInnerCorner;
    final selectedInner = height * 0.5; // `selected.inner-corner = 50%`
    final squareOuter = widget.size.innerCorner;
    final isVertical = widget.direction == Axis.vertical;
    final isRtl =
        !isVertical && Directionality.of(context) == TextDirection.rtl;
    final first = index == 0;
    final last = index == widget.items.length - 1;

    // The inner-facing corner value combines the press morph and the
    // selection morph (selection dominates).
    final inner = _lerp(
      _lerp(restInner, pressedInner, pressProgress),
      selectedInner,
      selectionMorph,
    );

    double leading;
    double trailing;
    if (widget.variant == ButtonGroupVariant.standard) {
      final rest = widget.shape == ButtonGroupShape.round ? pill : squareOuter;
      // The selected button swaps between round and square; otherwise the
      // inner-facing corners flatten slightly while pressed.
      if (selectionMorph > 0) {
        final swapped = widget.shape == ButtonGroupShape.round
            ? squareOuter
            : pill;
        leading = _lerp(rest, swapped, selectionMorph);
        trailing = leading;
      } else {
        leading = first ? rest : _lerp(rest, pressedInner, pressProgress);
        trailing = last ? rest : _lerp(rest, pressedInner, pressProgress);
      }
    } else {
      final outer = widget.shape == ButtonGroupShape.round ? pill : squareOuter;
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

  ({Color background, Color foreground, Color? border, double elevation})
  _colorsFor(BuildContext context, bool selected, bool disabled) {
    final colorScheme = Theme.of(context).colorScheme;

    final (background, foreground, border, elevation) = switch (widget.style) {
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

    // Custom [ButtonGroup.selectedColor] / [ButtonGroup.unselectedColor]
    // overrides replace the container color of their state and derive a
    // readable foreground (and an outlined border) from it.
    // The legacy [ButtonGroup.color] aliases [selectedColor].
    // ignore: deprecated_member_use_from_same_package
    final legacySelectedColor = widget.color;
    final custom = selected
        ? (widget.selectedColor ?? legacySelectedColor)
        : widget.unselectedColor;
    final resolvedBackground = custom ?? background;
    final resolvedForeground = custom != null
        ? _onColorFor(custom)
        : foreground;
    final resolvedBorder = custom != null
        ? (widget.style == ButtonGroupStyle.outlined ? custom : border)
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
  static double _contrastRatio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// The foreground color that reads best on [background]: black or white,
  /// whichever has the higher WCAG contrast ratio.
  static Color _onColorFor(Color background) {
    final white = _contrastRatio(background, Colors.white);
    final black = _contrastRatio(background, Colors.black);
    return white >= black ? Colors.white : Colors.black;
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = widget.items[index];
    final selected = widget.selected.contains(item.value);
    final colors = _colorsFor(context, selected, !item.enabled);
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final textStyle = widget.size
        .textStyle(context)
        ?.copyWith(color: colors.foreground);

    return AnimatedBuilder(
      animation: _pressAnimation,
      builder: (context, _) {
        final pressProgress = _pressAnimation.value;
        final width = _widthFor(index, pressProgress);
        return SizedBox(
          key: _itemKeys[index],
          height: widget.size.height,
          width: width,
          child: TweenAnimationBuilder<double>(
            tween: Tween(
              begin: 0,
              end: selected ? 1 : 0,
            ),
            duration: reduceMotion ? Duration.zero : _selectionMorphDuration,
            curve: Curves.easeInOutCubicEmphasized,
            builder: (context, selectionMorph, _) {
              final radii = _radiiFor(
                index,
                pressProgress,
                selectionMorph,
              );
              final shape = RoundedRectangleBorder(
                side: colors.border != null
                    ? BorderSide(color: colors.border!)
                    : BorderSide.none,
                borderRadius: BorderRadius.only(
                  topLeft: radii.tl,
                  topRight: radii.tr,
                  bottomLeft: radii.bl,
                  bottomRight: radii.br,
                ),
              );
              return Semantics(
                button: true,
                selected: selected,
                enabled: item.enabled,
                label: item.label ?? item.tooltip,
                child: Material(
                  color: colors.background,
                  elevation: colors.elevation,
                  shape: shape,
                  clipBehavior: Clip.antiAlias,
                  child: Tooltip(
                    message: item.tooltip ?? '',
                    child: InkWell(
                      onTap: item.enabled ? () => _handleTap(index) : null,
                      onHighlightChanged: item.enabled
                          ? (value) => value
                                ? _handlePressStart(index)
                                : _handlePressEnd()
                          : null,
                      child: Container(
                        padding: widget.size.padding,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                size: widget.size.iconSize,
                                color: colors.foreground,
                              ),
                              if (item.label != null) const SizedBox(width: 8),
                            ],
                            if (item.label != null)
                              Flexible(
                                child: Text(
                                  item.label!,
                                  style: textStyle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (selected && widget.showSelectedIcon) ...[
                              const SizedBox(width: 8),
                              widget.selectedIcon ??
                                  Icon(
                                    Icons.check,
                                    size: widget.size.iconSize,
                                    color: colors.foreground,
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// A synchronous estimate of the natural width of the item at [index],
  /// used to decide overflow on the very first frame before the post-frame
  /// measurement of [_naturalWidths] is available. The small margin keeps
  /// the estimate from ever undercounting the rendered width.
  double _estimatedNaturalWidth(int index) {
    final item = widget.items[index];
    final textStyle =
        widget.size.textStyle(context) ??
        Theme.of(context).textTheme.bodyMedium;
    var width = widget.size.padding.horizontal;
    if (item.icon != null) {
      width += widget.size.iconSize;
      if (item.label != null) width += 8;
    }
    if (item.label != null) {
      final painter = TextPainter(
        text: TextSpan(text: item.label, style: textStyle),
        maxLines: 1,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      width += painter.width;
    }
    if (widget.showSelectedIcon && widget.selected.contains(item.value)) {
      width += 8 + widget.size.iconSize;
    }
    return width + 4;
  }

  /// The number of leading items that fit in [availableWidth] next to the
  /// overflow menu button, or `null` when every item fits on its own (no
  /// overflow needed).
  ///
  /// Uses the measured natural widths when available and falls back to
  /// [_estimatedNaturalWidth] on the first frame so the row never renders
  /// more items than fit.
  int? _overflowFit(double availableWidth, double gap, double overflowWidth) {
    if (widget.items.length <= 1) return null;

    double widthAt(int index) {
      final measured = _naturalWidths[index];
      return measured != null && measured > 0
          ? measured
          : _estimatedNaturalWidth(index);
    }

    // Everything fits without the overflow button?
    var all = 0.0;
    for (var i = 0; i < widget.items.length; i++) {
      all += widthAt(i) + (i > 0 ? gap : 0);
    }
    if (all <= availableWidth) return null;

    // Greedily fit leading items; every item carries a trailing gap and the
    // overflow button sits at the end.
    var count = 0;
    var used = 0.0;
    for (var i = 0; i < widget.items.length; i++) {
      final next = used + widthAt(i) + gap + overflowWidth;
      if (next > availableWidth) break;
      used += widthAt(i) + gap;
      count++;
    }
    // When nothing fits next to the overflow button, collapse every button
    // into the menu and show the overflow button on its own.
    return count.clamp(0, widget.items.length - 1);
  }

  /// The corner radii for the overflow menu button, which sits at the end of
  /// the group and inherits the group's outer corner on the trailing edge.
  ({Radius tl, Radius tr, Radius bl, Radius br}) _overflowRadii() {
    final height = widget.size.height;
    final pill = height / 2;
    final inner = widget.size.innerCorner;
    final rest = widget.shape == ButtonGroupShape.round ? pill : inner;
    final isVertical = widget.direction == Axis.vertical;
    final isRtl =
        !isVertical && Directionality.of(context) == TextDirection.rtl;
    // Standard items rest with the outer shape on every corner; connected
    // items face the group with their inner corner.
    final double leading;
    final double trailing;
    if (widget.variant == ButtonGroupVariant.standard) {
      leading = rest;
      trailing = rest;
    } else {
      leading = inner;
      trailing = rest;
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

  /// The popup menu entries for the items hidden behind the overflow button.
  List<PopupMenuEntry<int>> _overflowMenuItems(
    BuildContext context,
    List<int> indices,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      for (final index in indices)
        PopupMenuItem<int>(
          value: index,
          enabled: widget.items[index].enabled,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.items[index].icon != null) ...[
                Icon(
                  widget.items[index].icon,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.items[index].label ??
                      widget.items[index].tooltip ??
                      '',
                ),
              ),
              if (widget.selected.contains(widget.items[index].value)) ...[
                const SizedBox(width: 8),
                Icon(Icons.check, size: 18, color: colorScheme.primary),
              ],
            ],
          ),
        ),
    ];
  }

  /// The overflow menu button (⋯) shown in place of the collapsed trailing
  /// items. It mirrors the group's unselected styling and inherits the
  /// trailing edge's outer corner.
  Widget _buildOverflowButton(BuildContext context, int firstHidden) {
    final hiddenIndices = [
      for (var i = firstHidden; i < widget.items.length; i++) i,
    ];
    final disabled = !widget.items
        .skip(firstHidden)
        .any((item) => item.enabled);
    final colors = _colorsFor(context, false, disabled);
    final overflowWidth = widget.size.iconSize + widget.size.padding.horizontal;
    final radii = _overflowRadii();
    final shape = RoundedRectangleBorder(
      side: colors.border != null
          ? BorderSide(color: colors.border!)
          : BorderSide.none,
      borderRadius: BorderRadius.only(
        topLeft: radii.tl,
        topRight: radii.tr,
        bottomLeft: radii.bl,
        bottomRight: radii.br,
      ),
    );
    return Material(
      color: colors.background,
      elevation: colors.elevation,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<int>(
        tooltip: 'More options',
        enabled: !disabled,
        onSelected: _handleTap,
        itemBuilder: (context) => _overflowMenuItems(context, hiddenIndices),
        child: SizedBox(
          width: overflowWidth,
          height: widget.size.height,
          child: Icon(
            Icons.more_horiz,
            size: widget.size.iconSize,
            color: colors.foreground,
          ),
        ),
      ),
    );
  }

  /// Builds the group's row/column of buttons.
  ///
  /// When [visibleCount] is set, only that many leading items are shown and
  /// an overflow menu button takes the place of the trailing items.
  Widget _buildRow(
    double pressProgress,
    double gap, {
    int? visibleCount,
  }) {
    final isVertical = widget.direction == Axis.vertical;
    final showingOverflow =
        visibleCount != null && visibleCount < widget.items.length;
    final count = showingOverflow ? visibleCount : widget.items.length;

    final children = <Widget>[];
    for (var i = 0; i < count; i++) {
      if (i > 0) {
        children.add(
          isVertical ? SizedBox(height: gap) : SizedBox(width: gap),
        );
      }
      final item = _buildItem(context, i);
      children.add(
        _flexible && !isVertical
            ? Expanded(flex: _flexFor(i, pressProgress), child: item)
            : item,
      );
    }

    if (showingOverflow) {
      // Only a gap separates the last visible button from the overflow
      // button; when nothing is visible the overflow button stands alone.
      if (count > 0) {
        children.add(
          isVertical ? SizedBox(height: gap) : SizedBox(width: gap),
        );
      }
      children.add(_buildOverflowButton(context, count));
    }

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _flexible
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        children: children,
      );
    }
    return Row(
      mainAxisSize: _flexible ? MainAxisSize.max : MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.direction == Axis.vertical;
    final connected = widget.variant == ButtonGroupVariant.connected;
    final gap = connected ? 2.0 : widget.size.standardGap;
    final overflow =
        widget.overflowMode == ButtonGroupOverflowMode.menu &&
        !isVertical &&
        !_flexible;

    // Flexible groups (connected, or standard with [ButtonGroup.expanded])
    // span the width of their surface and share it equally; fixed standard
    // groups hug their buttons. The container itself is not a focusable or
    // labeled element per the button group accessibility spec.
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _pressAnimation,
          builder: (context, _) {
            final pressProgress = _pressAnimation.value;
            if (overflow) {
              final overflowWidth =
                  widget.size.iconSize + widget.size.padding.horizontal;
              final fit = _overflowFit(
                constraints.maxWidth,
                gap,
                overflowWidth,
              );
              return _buildRow(
                pressProgress,
                gap,
                visibleCount: fit,
              );
            }
            return _buildRow(pressProgress, gap);
          },
        );
      },
    );
  }
}

@Preview(name: 'Button Group - Standard', size: Size.fromHeight(280))
Widget buttonGroupStandardPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(body: Center(child: _ButtonGroupPreview())),
  );
}

class _ButtonGroupPreview extends StatefulWidget {
  const _ButtonGroupPreview();

  @override
  State<_ButtonGroupPreview> createState() => _ButtonGroupPreviewState();
}

class _ButtonGroupPreviewState extends State<_ButtonGroupPreview> {
  final Set<ButtonGroupSize> _sizes = {ButtonGroupSize.md};
  Set<int> _colors = {1, 3};
  ViewMode _view = ViewMode.list;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Standard - single select'),
          const SizedBox(height: 12),
          ButtonGroup<ButtonGroupSize>(
            items: const [
              ButtonGroupItem(
                value: ButtonGroupSize.xs,
                label: 'XS',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.sm,
                label: 'S',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.md,
                label: 'M',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.lg,
                label: 'L',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.xl,
                label: 'XL',
                icon: Icons.done,
              ),
            ],
            selected: _sizes,
            onSelectionChanged: (next) => setState(
              () => _sizes
                ..clear()
                ..addAll(next),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Standard - expanded (flexible)'),
          const SizedBox(height: 12),
          SizedBox(
            width: 420,
            child: ButtonGroup<ButtonGroupSize>(
              expanded: true,
              items: const [
                ButtonGroupItem(value: ButtonGroupSize.sm, label: 'S'),
                ButtonGroupItem(value: ButtonGroupSize.md, label: 'M'),
                ButtonGroupItem(value: ButtonGroupSize.lg, label: 'L'),
              ],
              selected: _sizes,
              onSelectionChanged: (next) => setState(
                () => _sizes
                  ..clear()
                  ..addAll(next),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Standard - custom color'),
          const SizedBox(height: 12),
          ButtonGroup<ButtonGroupSize>(
            selectedColor: const Color(0xFF00696D),
            unselectedColor: const Color(0xFFE3F2F2),
            items: const [
              ButtonGroupItem(value: ButtonGroupSize.sm, label: 'S'),
              ButtonGroupItem(value: ButtonGroupSize.md, label: 'M'),
              ButtonGroupItem(value: ButtonGroupSize.lg, label: 'L'),
            ],
            selected: _sizes,
            onSelectionChanged: (next) => setState(
              () => _sizes
                ..clear()
                ..addAll(next),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Standard - overflow menu (narrow)'),
          const SizedBox(height: 12),
          SizedBox(
            width: 260,
            child: ButtonGroup<ButtonGroupSize>(
              overflowMode: ButtonGroupOverflowMode.menu,
              items: const [
                ButtonGroupItem(value: ButtonGroupSize.xs, label: 'XS'),
                ButtonGroupItem(value: ButtonGroupSize.sm, label: 'S'),
                ButtonGroupItem(value: ButtonGroupSize.md, label: 'M'),
                ButtonGroupItem(value: ButtonGroupSize.lg, label: 'L'),
                ButtonGroupItem(value: ButtonGroupSize.xl, label: 'XL'),
              ],
              selected: _sizes,
              onSelectionChanged: (next) => setState(
                () => _sizes
                  ..clear()
                  ..addAll(next),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Connected - single select'),
          const SizedBox(height: 12),
          ButtonGroup<ViewMode>(
            variant: ButtonGroupVariant.connected,
            showSelectedIcon: true,
            items: const [
              ButtonGroupItem(
                value: ViewMode.list,
                label: 'List',
                icon: Icons.view_list,
              ),
              ButtonGroupItem(
                value: ViewMode.grid,
                label: 'Grid',
                icon: Icons.grid_view,
              ),
              ButtonGroupItem(
                value: ViewMode.calendar,
                label: 'Calendar',
                icon: Icons.calendar_month,
              ),
            ],
            selected: {_view},
            onSelectionChanged: (next) => setState(() => _view = next.first),
          ),
          const SizedBox(height: 40),
          const Text('Connected - multi select'),
          const SizedBox(height: 12),
          ButtonGroup<int>(
            variant: ButtonGroupVariant.connected,
            multiSelectionEnabled: true,
            emptySelectionAllowed: true,
            items: const [
              ButtonGroupItem(value: 1, label: 'Red'),
              ButtonGroupItem(value: 2, label: 'Green'),
              ButtonGroupItem(value: 3, label: 'Blue'),
            ],
            selected: _colors,
            onSelectionChanged: (next) => setState(() => _colors = next),
          ),
        ],
      ),
    );
  }
}

enum ViewMode { list, grid, calendar }
