import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/buttons/button_group_colors.dart';
import 'package:rhizu/src/ui/components/buttons/button_group_geometry.dart';
import 'package:rhizu/src/ui/components/buttons/button_group_item.dart';
import 'package:rhizu/src/ui/components/buttons/button_group_tokens.dart';
import 'package:rhizu/src/ui/components/indicators/animation/spring_curve.dart';
import 'package:rhizu/src/ui/styles/motion/tokens.dart';

export 'button_group_item.dart';
export 'button_group_tokens.dart';

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

  /// The pure layout math for the current configuration and text direction.
  ButtonGroupGeometry get _geometry => ButtonGroupGeometry(
    size: widget.size,
    variant: widget.variant,
    shape: widget.shape,
    direction: widget.direction,
    textDirection: Directionality.of(context),
    itemCount: widget.items.length,
    expanded: widget.expanded,
  );

  /// The color resolver for the current style and custom-color overrides.
  ButtonGroupPalette get _palette => ButtonGroupPalette(
    style: widget.style,
    selectedColor: widget.selectedColor,
    unselectedColor: widget.unselectedColor,
    // The legacy [ButtonGroup.color] aliases [ButtonGroup.selectedColor].
    // ignore: deprecated_member_use_from_same_package
    legacyColor: widget.color,
  );

  /// The measured width of [index], falling back to a synchronous estimate
  /// before the post-frame measurement completes.
  double _effectiveNaturalWidth(int index) {
    final measured = _naturalWidths[index];
    return measured != null && measured > 0
        ? measured
        : _estimatedNaturalWidth(index);
  }

  Widget _buildItem(
    BuildContext context,
    ButtonGroupGeometry geometry,
    int index,
  ) {
    final item = widget.items[index];
    final selected = widget.selected.contains(item.value);
    final colors = _palette.resolve(
      Theme.of(context).colorScheme,
      selected: selected,
      disabled: !item.enabled,
    );
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final textStyle = widget.size
        .textStyle(context)
        ?.copyWith(color: colors.foreground);

    return AnimatedBuilder(
      animation: _pressAnimation,
      builder: (context, _) {
        final pressProgress = _pressAnimation.value;
        final width = geometry.widthFor(
          index: index,
          pressProgress: pressProgress,
          pressedIndex: _pressedIndex,
          naturalWidths: _naturalWidths,
          widthsMeasured: _widthsMeasured,
        );
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
              final radii = geometry.radiiFor(
                index: index,
                pressProgress: pressProgress,
                selectionMorph: selectionMorph,
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
  Widget _buildOverflowButton(
    BuildContext context,
    ButtonGroupGeometry geometry,
    int firstHidden,
  ) {
    final hiddenIndices = [
      for (var i = firstHidden; i < widget.items.length; i++) i,
    ];
    final disabled = !widget.items
        .skip(firstHidden)
        .any((item) => item.enabled);
    final colors = _palette.resolve(
      Theme.of(context).colorScheme,
      selected: false,
      disabled: disabled,
    );
    final overflowWidth = geometry.overflowButtonWidth;
    final radii = geometry.overflowRadii();
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
    ButtonGroupGeometry geometry,
    double pressProgress, {
    int? visibleCount,
  }) {
    final isVertical = geometry.isVertical;
    final showingOverflow =
        visibleCount != null && visibleCount < widget.items.length;
    final count = showingOverflow ? visibleCount : widget.items.length;
    final gap = geometry.gap;

    final children = <Widget>[];
    for (var i = 0; i < count; i++) {
      if (i > 0) {
        children.add(
          isVertical ? SizedBox(height: gap) : SizedBox(width: gap),
        );
      }
      final item = _buildItem(context, geometry, i);
      children.add(
        geometry.isFlexible && !isVertical
            ? Expanded(
                flex: geometry.flexFor(
                  index: i,
                  pressProgress: pressProgress,
                  pressedIndex: _pressedIndex,
                ),
                child: item,
              )
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
      children.add(_buildOverflowButton(context, geometry, count));
    }

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: geometry.isFlexible
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        children: children,
      );
    }
    return Row(
      mainAxisSize: geometry.isFlexible ? MainAxisSize.max : MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final geometry = _geometry;
    final overflow =
        widget.overflowMode == ButtonGroupOverflowMode.menu &&
        !geometry.isVertical &&
        !geometry.isFlexible;

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
              final fit = ButtonGroupGeometry.overflowFitCount(
                widths: [
                  for (var i = 0; i < widget.items.length; i++)
                    _effectiveNaturalWidth(i),
                ],
                availableWidth: constraints.maxWidth,
                gap: geometry.gap,
                overflowWidth: geometry.overflowButtonWidth,
              );
              return _buildRow(
                geometry,
                pressProgress,
                visibleCount: fit,
              );
            }
            return _buildRow(geometry, pressProgress);
          },
        );
      },
    );
  }
}
