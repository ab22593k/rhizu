import 'package:flutter/material.dart'
    hide CircularProgressIndicator, LinearProgressIndicator, ProgressIndicator;

import 'package:rhizu/src/ui/components/buttons/split_button_geometry.dart';
import 'package:rhizu/src/ui/components/buttons/split_button_item.dart';
import 'package:rhizu/src/ui/components/buttons/split_button_menu.dart';
import 'package:rhizu/src/ui/components/buttons/split_button_tokens.dart';
import 'package:rhizu/src/ui/components/indicators/progress.dart';

export 'split_button_item.dart';
export 'split_button_tokens.dart';

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
              child: SplitButtonMenu<T>(
                items: widget.items,
                menuBuilder: widget.menuBuilder,
                onDismiss: _closeMenu,
                onSelected: widget.onSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final geometry = SplitButtonGeometry(
      size: widget.size,
      shape: widget.shape,
    );
    final colors = SplitButtonPalette(
      emphasis: widget.emphasis,
    ).resolve(Theme.of(context).colorScheme);

    // While loading, both segments become non-interactive.
    final interactive = widget.enabled && !widget.isLoading;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        height: geometry.height,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLeadingSegment(
              context,
              geometry: geometry,
              colors: colors,
              interactive: interactive,
            ),
            const SizedBox(width: 2),
            _buildTrailingSegment(
              geometry: geometry,
              colors: colors,
              interactive: interactive,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the primary action segment.
  Widget _buildLeadingSegment(
    BuildContext context, {
    required SplitButtonGeometry geometry,
    required SplitButtonColors colors,
    required bool interactive,
  }) {
    final textStyle = widget.size
        .textStyle(context)
        ?.copyWith(color: colors.foreground);

    return Material(
      color: colors.background,
      elevation: colors.elevation,
      shape: RoundedRectangleBorder(
        side: colors.border != null
            ? BorderSide(color: colors.border!)
            : BorderSide.none,
        borderRadius: geometry.leadingBorderRadius(),
      ),
      clipBehavior: Clip.antiAlias,
      child: Tooltip(
        message: widget.leadingTooltip ?? '',
        child: InkWell(
          onTap: interactive ? widget.onPressed : null,
          child: Container(
            height: geometry.height,
            padding: geometry.leadingPadding(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isLoading)
                  _buildLoadingIndicator(colors.foreground)
                else if (widget.leadingIcon != null) ...[
                  Icon(
                    widget.leadingIcon,
                    size: widget.size.iconSize,
                    color: colors.foreground,
                  ),
                  if (widget.label != null)
                    SizedBox(width: geometry.iconLabelGap()),
                ],
                if (widget.label != null) Text(widget.label!, style: textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the menu segment, animating its morph while the menu opens.
  Widget _buildTrailingSegment({
    required SplitButtonGeometry geometry,
    required SplitButtonColors colors,
    required bool interactive,
  }) {
    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        final morphProgress = geometry.morphProgress(_morphAnimation.value);
        final currentTrailingWidth = geometry.trailingWidthFor(morphProgress);
        final shape = RoundedRectangleBorder(
          side: colors.border != null
              ? BorderSide(color: colors.border!)
              : BorderSide.none,
          borderRadius: geometry.trailingBorderRadius(morphProgress),
        );

        return Material(
          color: colors.background,
          elevation: colors.elevation,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: Tooltip(
            message: widget.trailingTooltip ?? '',
            child: InkWell(
              onTap: interactive ? _toggleMenu : null,
              child: Container(
                height: geometry.height,
                width: geometry.canMorph
                    ? null
                    : SplitButtonGeometry.minimumTrailingWidth,
                constraints: BoxConstraints(
                  minWidth: geometry.canMorph
                      ? currentTrailingWidth
                      : SplitButtonGeometry.minimumTrailingWidth,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: geometry.horizontalPaddingFor(morphProgress),
                ),
                child: Center(
                  child: Transform.translate(
                    offset: Offset(
                      geometry.chevronOffset(
                        menuOpen: _isMenuOpen,
                        alignment: widget.trailingAlignment,
                      ),
                      0,
                    ),
                    child: RotationTransition(
                      turns: _rotateAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: widget.size.iconSize,
                        color: colors.foreground,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the indeterminate loading indicator shown while
  /// [SplitButton.isLoading].
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
}

// --- Previews ---
