import 'dart:math' as math;

import 'package:flutter/material.dart'
    hide CircularProgressIndicator, LinearProgressIndicator, ProgressIndicator;
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/components/indicators/progress.dart';

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

/// An item for the split button menu.
class SplitButtonItem<T> {
  const SplitButtonItem({
    required this.value,
    required this.child,
    this.enabled = true,
  });

  final T value;
  final Object child; // String or Widget
  final bool enabled;
}

/// Expressive Split Button.
class SplitButton<T> extends StatefulWidget {
  const SplitButton({
    super.key,
    this.size = SplitButtonSize.md,
    this.shape = SplitButtonShape.round,
    this.emphasis = SplitButtonEmphasis.tonal,
    this.label,
    this.leadingIcon,
    this.onPressed,
    this.items,
    this.menuBuilder,
    this.onSelected,
    this.trailingAlignment = SplitButtonTrailingAlignment.opticalCenter,
    this.leadingTooltip,
    this.trailingTooltip,
    this.enabled = true,
    this.isLoading = false,
  }) : assert(
         items != null || menuBuilder != null,
         'Either items or menuBuilder must be provided',
       );

  final SplitButtonSize size;
  final SplitButtonShape shape;
  final SplitButtonEmphasis emphasis;
  final String? label;
  final IconData? leadingIcon;
  final VoidCallback? onPressed;
  final List<SplitButtonItem<T>>? items;
  final List<PopupMenuEntry<T>> Function(BuildContext)? menuBuilder;
  final ValueChanged<T>? onSelected;
  final SplitButtonTrailingAlignment trailingAlignment;
  final String? leadingTooltip;
  final String? trailingTooltip;
  final bool enabled;

  /// Whether the button is busy executing its primary action.
  ///
  /// When `true`, the leading segment shows an indeterminate loading
  /// indicator in place of its icon (the label, if any, stays visible so the
  /// button keeps its width), and both segments are non-interactive
  /// (pressing the label does nothing and the trailing menu cannot open).
  /// Any open menu is dismissed.
  ///
  /// Follows the M3 guidance for progress indicators in buttons:
  /// - The active indicator uses the button's foreground (icon/label) color
  ///   to keep at least 3:1 contrast with the container.
  /// - The track is removed.
  /// - Small sizes (XS/SM) use the flat shape; larger sizes use the wavy
  ///   shape since it reads better at larger dimensions.
  final bool isLoading;

  @override
  State<SplitButton<T>> createState() => _SplitButtonState<T>();
}

class _SplitButtonState<T> extends State<SplitButton<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _morphAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void didUpdateWidget(covariant SplitButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the action starts loading, close any open menu so the button can
    // settle into its busy state. A rebuild follows this callback anyway, so
    // the menu state is mutated directly rather than via setState.
    if (widget.isLoading && !oldWidget.isLoading && _isMenuOpen) {
      _dismissMenu();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    setState(() {
      _isMenuOpen = true;
      _controller.forward();
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
      _controller.reverse();
    });
    _dismissMenu();
  }

  /// Removes the open menu overlay without triggering a rebuild.
  void _dismissMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            left: offset.dx + size.width - 200, // Align right
            top: offset.dy + size.height,
            width: 200,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(
                size.width - 200, // Align right edge
                size.height,
              ),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      widget.items?.map((item) {
                        return ListTile(
                          title: item.child is Widget
                              ? (item.child as Widget)
                              : Text(item.child.toString()),
                          enabled: item.enabled,
                          onTap: () {
                            _closeMenu();
                            widget.onSelected?.call(item.value);
                          },
                        );
                      }).toList() ??
                      widget.menuBuilder!(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color foregroundColor;
    Color? borderColor;
    double elevation = 0;

    switch (widget.emphasis) {
      case SplitButtonEmphasis.filled:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
      case SplitButtonEmphasis.tonal:
        backgroundColor = colorScheme.secondaryContainer;
        foregroundColor = colorScheme.onSecondaryContainer;
      case SplitButtonEmphasis.elevated:
        backgroundColor = colorScheme.surfaceContainerLow;
        foregroundColor = colorScheme.primary;
        elevation = 1;
      case SplitButtonEmphasis.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        borderColor = colorScheme.outline;
      case SplitButtonEmphasis.text:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
    }

    final height = widget.size.height;
    final innerRadius = widget.size.innerCornerRadius;
    final trailingWidth = widget.size.trailingWidth;

    // Morphing Logic
    final isRound = widget.shape == SplitButtonShape.round;
    final isLarge =
        widget.size == SplitButtonSize.md ||
        widget.size == SplitButtonSize.lg ||
        widget.size == SplitButtonSize.xl;
    final canMorph = isRound && isLarge;

    final textStyle = widget.size
        .textStyle(context)
        ?.copyWith(color: foregroundColor);

    // While loading, both segments become non-interactive.
    final interactive = widget.enabled && !widget.isLoading;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        height: height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Leading Segment
            Material(
              color: backgroundColor,
              elevation: elevation,
              shape: RoundedRectangleBorder(
                side: borderColor != null
                    ? BorderSide(color: borderColor)
                    : BorderSide.none,
                borderRadius: BorderRadius.only(
                  topLeft: isRound
                      ? Radius.circular(height / 2)
                      : Radius.circular(innerRadius),
                  bottomLeft: isRound
                      ? Radius.circular(height / 2)
                      : Radius.circular(innerRadius),
                  topRight: Radius.circular(innerRadius),
                  bottomRight: Radius.circular(innerRadius),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Tooltip(
                message: widget.leadingTooltip ?? '',
                child: InkWell(
                  onTap: interactive ? widget.onPressed : null,
                  child: Container(
                    height: height,
                    padding: _getLeadingPadding(widget.size),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading)
                          _buildLoadingIndicator(foregroundColor)
                        else if (widget.leadingIcon != null) ...[
                          Icon(
                            widget.leadingIcon,
                            size: widget.size.iconSize,
                            color: foregroundColor,
                          ),
                          if (widget.label != null)
                            SizedBox(width: _getIconLabelGap(widget.size)),
                        ],
                        if (widget.label != null)
                          Text(widget.label!, style: textStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            // Trailing Segment
            AnimatedBuilder(
              animation: _morphAnimation,
              builder: (context, child) {
                final morphProgress = canMorph ? _morphAnimation.value : 0.0;

                // Calculate morphed width: lerp from base width to full height (circle)
                final currentTrailingWidth = math.max(
                  trailingWidth,
                  height * morphProgress,
                );

                // Calculate padding based on morph
                final horizontalPadding = canMorph
                    ? (1.0 - morphProgress) *
                          (trailingWidth - widget.size.iconSize) /
                          2
                    : 0.0;

                final shape = RoundedRectangleBorder(
                  side: borderColor != null
                      ? BorderSide(color: borderColor)
                      : BorderSide.none,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(
                      canMorph
                          ? math.max(innerRadius, (height / 2) * morphProgress)
                          : innerRadius,
                    ),
                    bottomLeft: Radius.circular(
                      canMorph
                          ? math.max(innerRadius, (height / 2) * morphProgress)
                          : innerRadius,
                    ),
                    topRight: isRound
                        ? Radius.circular(height / 2)
                        : Radius.circular(innerRadius),
                    bottomRight: isRound
                        ? Radius.circular(height / 2)
                        : Radius.circular(innerRadius),
                  ),
                );

                return Material(
                  color: backgroundColor,
                  elevation: elevation,
                  shape: shape,
                  clipBehavior: Clip.antiAlias,
                  child: Tooltip(
                    message: widget.trailingTooltip ?? '',
                    child: InkWell(
                      onTap: interactive ? _toggleMenu : null,
                      child: Container(
                        height: height,
                        width: canMorph ? null : 48.0, // Fixed width for small
                        constraints: BoxConstraints(
                          minWidth: canMorph
                              ? currentTrailingWidth
                              : 48.0, // Minimum touch target
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ), // Handled by alignment
                        child: Center(
                          child: Transform.translate(
                            offset: Offset(
                              widget.trailingAlignment ==
                                          SplitButtonTrailingAlignment
                                              .opticalCenter &&
                                      !_isMenuOpen
                                  ? widget.size.opticalChevronOffset
                                  : 0,
                              0,
                            ),
                            child: RotationTransition(
                              turns: _rotateAnimation,
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: widget.size.iconSize,
                                color: foregroundColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the indeterminate loading indicator shown while [SplitButton.isLoading].
  ///
  /// Per the M3 progress-indicator-in-button guidance:
  /// - The active indicator matches the button's foreground color so it keeps
  ///   at least 3:1 contrast against the container.
  /// - The track is removed.
  /// - Very small buttons use the flat shape (the wavy shape isn't legible at
  ///   small sizes); larger buttons use the wavy shape.
  Widget _buildLoadingIndicator(Color foregroundColor) {
    final isSmall =
        widget.size == SplitButtonSize.xs || widget.size == SplitButtonSize.sm;

    return ProgressIndicator(
      size: ProgressIndicatorSize.from(
        diameter: widget.size.iconSize,
      ),
      shape: isSmall
          ? ProgressIndicatorShape.flat
          : ProgressIndicatorShape.wavy,
      activeColor: foregroundColor,
      trackColor: Colors.transparent,
    );
  }

  EdgeInsetsGeometry _getLeadingPadding(SplitButtonSize size) {
    switch (size) {
      case SplitButtonSize.xs:
        return const EdgeInsets.fromLTRB(12, 0, 10, 0);
      case SplitButtonSize.sm:
        return const EdgeInsets.fromLTRB(16, 0, 12, 0);
      case SplitButtonSize.md:
        return const EdgeInsets.fromLTRB(24, 0, 24, 0);
      case SplitButtonSize.lg:
        return const EdgeInsets.fromLTRB(48, 0, 48, 0);
      case SplitButtonSize.xl:
        return const EdgeInsets.fromLTRB(64, 0, 64, 0);
    }
  }

  double _getIconLabelGap(SplitButtonSize size) {
    switch (size) {
      case SplitButtonSize.xs:
        return 4.0;
      case SplitButtonSize.sm:
      case SplitButtonSize.md:
        return 8.0;
      case SplitButtonSize.lg:
        return 12.0;
      case SplitButtonSize.xl:
        return 16.0;
    }
  }
}

// --- Previews ---

@Preview(name: 'Split Button - Sizes', size: Size.fromHeight(500))
Widget previewSplitButtonSizes() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            SplitButton(
              size: SplitButtonSize.xs,
              label: 'XS',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              size: SplitButtonSize.sm,
              label: 'Small',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              label: 'Medium',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              size: SplitButtonSize.lg,
              label: 'Large',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              size: SplitButtonSize.xl,
              label: 'Extra Large',
              onPressed: () {},
              items: const [],
            ),
          ],
        ),
      ),
    ),
  );
}
