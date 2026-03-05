import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:rhizu/src/components/buttons/split_button.dart';
import 'package:rhizu/src/components/fab_menu.dart';
import 'package:rhizu/src/components/indicators/progress.dart' as rhizu;
import 'package:rhizu/src/styles/shapes/tokens.dart';

/// The type of [RZToolbar].
enum ToolbarType {
  /// A toolbar docked at the bottom of the screen (replaces BottomAppBar).
  /// Typically full width.
  docked,

  /// A toolbar that floats above content, usually with rounded corners.
  /// Can be horizontal or vertical.
  floating,
}

/// The layout direction of the [RZToolbar].
enum ToolbarLayout {
  horizontal,
  vertical,
}

/// The color style of the [RZToolbar].
enum ToolbarStyle {
  /// Uses standard surface container colors (subtle).
  standard,

  /// Uses primary/secondary container colors (emphasized).
  vibrant,
}

/// A Material 3 Expressive Toolbar.
///
/// Toolbars display frequently used actions relevant to the current screen.
/// M3 Expressive introduces docked and floating variants with vibrant colors
/// and flexible layouts.
///
/// See also:
/// * [M3 Toolbars Overview](https://m3.material.io/components/toolbars/overview)
class RZToolbar extends StatefulWidget {
  const RZToolbar({
    required this.children,
    super.key,
    this.type = ToolbarType.floating,
    this.layout = ToolbarLayout.horizontal,
    this.style = ToolbarStyle.standard,
    this.centerTitle = false,
    this.leading,
    this.trailing,
    this.fab,
    this.fabMenu,
    this.scrollable = false,
    this.backgroundColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.shape,
  }) : assert(
         fab == null || fabMenu == null,
         'Cannot provide both fab and fabMenu. Use fab for a custom widget '
         'or fabMenu for the built-in RZFabMenu.',
       );

  /// The widgets below this widget in the tree.
  /// Typically [IconButton], [SplitButton], or other actions.
  final List<Widget> children;

  /// The type of toolbar: [ToolbarType.docked] or [ToolbarType.floating].
  final ToolbarType type;

  /// The layout direction: [ToolbarLayout.horizontal] or [ToolbarLayout.vertical].
  /// Note: [ToolbarType.docked] is typically horizontal.
  final ToolbarLayout layout;

  /// The visual style: [ToolbarStyle.standard] or [ToolbarStyle.vibrant].
  final ToolbarStyle style;

  /// Whether to center the title/content (mainly for docked).
  final bool centerTitle;

  /// A widget to display before the [children] (e.g. a menu icon).
  final Widget? leading;

  /// A widget to display after the [children] (e.g. an overflow menu).
  final Widget? trailing;

  /// A Floating Action Button to embed or pair with the toolbar.
  ///
  /// Mutually exclusive with [fabMenu]. Use this for a fully custom FAB widget.
  final Widget? fab;

  /// Optional built-in FAB menu configuration.
  ///
  /// When provided, the toolbar automatically creates an [RZFabMenu] from this
  /// configuration. Mutually exclusive with [fab].
  final RZFabMenuConfig? fabMenu;

  /// Whether the content is scrollable (useful for many actions).
  final bool scrollable;

  /// Custom background color. If null, determined by [style].
  final Color? backgroundColor;

  /// Custom elevation. If null, determined by [type].
  final double? elevation;

  /// Custom padding.
  final EdgeInsetsGeometry? padding;

  /// Custom border radius.
  final BorderRadiusGeometry? borderRadius;

  /// Custom shape. If null, determined by [type] and [borderRadius].
  final ShapeBorder? shape;

  @override
  State<RZToolbar> createState() => _RZToolbarState();
}

class _RZToolbarState extends State<RZToolbar> {
  late ScrollController _scrollController;
  double _scrollProgress = 0.0;
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      if (_showIndicator) setState(() => _showIndicator = false);
      return;
    }

    if (!_showIndicator) setState(() => _showIndicator = true);

    final currentScroll = _scrollController.offset;
    final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);

    if (progress != _scrollProgress) {
      setState(() => _scrollProgress = progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 0. Resolve effective FAB (fab slot vs. built-in fabMenu)
    final effectiveFab =
        widget.fab ??
        (widget.fabMenu != null
            ? RZFabMenu(
                children: widget.fabMenu!.items,
                alignment: widget.fabMenu!.alignment,
                icon: widget.fabMenu!.icon,
              )
            : null);

    // 1. Determine Colors
    Color effectiveBackgroundColor;
    Color effectiveOnBackgroundColor;

    if (widget.backgroundColor != null) {
      effectiveBackgroundColor = widget.backgroundColor!;
      effectiveOnBackgroundColor =
          ThemeData.estimateBrightnessForColor(effectiveBackgroundColor) ==
              Brightness.dark
          ? Colors.white
          : Colors.black;
    } else {
      switch (widget.style) {
        case ToolbarStyle.standard:
          effectiveBackgroundColor = colorScheme.surfaceContainer;
          effectiveOnBackgroundColor = colorScheme.onSurface;
        case ToolbarStyle.vibrant:
          effectiveBackgroundColor = colorScheme.primaryContainer;
          effectiveOnBackgroundColor = colorScheme.onPrimaryContainer;
      }
    }

    // 2. Determine Shape & Elevation
    ShapeBorder effectiveShape;
    var effectiveElevation = widget.elevation ?? 0;

    if (widget.shape != null) {
      effectiveShape = widget.shape!;
      effectiveElevation =
          widget.elevation ?? (widget.type == ToolbarType.docked ? 0.0 : 2.0);
    } else if (widget.type == ToolbarType.docked) {
      // Docked: Rectangular
      // M3 Spec: "No shadow" for docked.
      effectiveShape = const RoundedRectangleBorder();
      effectiveElevation = widget.elevation ?? 0.0;
    } else {
      // Floating: High border radius (Extra Large token)
      // M3 Spec: "Low elevation"
      effectiveShape = RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? ShapeTokens.borderRadiusExtraLarge,
      );
      effectiveElevation = widget.elevation ?? 2.0; // Floating default
    }

    // 3. Layout Children
    //
    // Docked toolbars must NOT use Spacer inside a SingleChildScrollView,
    // because horizontal scroll views give the Row unbounded width, making
    // Expanded/Spacer impossible to resolve (throws RenderFlex unbounded
    // constraint error). Instead, docked toolbars use a plain Row with
    // MainAxisSize.max so that Spacer works correctly.
    final itemsLeading = <Widget>[];
    final itemsTrailing = <Widget>[];
    final itemsMain = <Widget>[];

    if (widget.leading != null) {
      itemsLeading.add(widget.leading!);
      itemsLeading.add(const SizedBox(width: 8, height: 8)); // Gap
    }

    itemsMain.addAll(
      widget.children
          .expand((child) => [child, const SizedBox(width: 8, height: 8)])
          .take(widget.children.length * 2 - 1),
    );

    if (widget.trailing != null) {
      itemsTrailing.add(const SizedBox(width: 8, height: 8)); // Gap
      itemsTrailing.add(widget.trailing!);
    }

    // FAB Handling (always treated as trailing-side)
    if (effectiveFab != null) {
      itemsTrailing.add(const SizedBox(width: 16, height: 16));
      itemsTrailing.add(effectiveFab);
    }

    // Orientation & Wrapping
    Widget content;
    if (widget.layout == ToolbarLayout.horizontal) {
      if (widget.type == ToolbarType.docked) {
        // Docked: use a plain Row with MainAxisSize.max so Spacer works.
        // The parent (BottomAppBar / full-width container) provides finite
        // width constraints, so Spacer/Expanded are safe here.
        content = Row(
          mainAxisAlignment: widget.centerTitle
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            ...itemsLeading,
            ...itemsMain,
            if (itemsTrailing.isNotEmpty) const Spacer(),
            ...itemsTrailing,
          ],
        );
      } else {
        // Floating / scrollable: use SingleChildScrollView. No Spacer here
        // because the Row has unbounded width inside the scroll view.
        final allItems = [
          ...itemsLeading,
          ...itemsMain,
          ...itemsTrailing,
        ];
        content = NotificationListener<ScrollMetricsNotification>(
          onNotification: (notification) {
            _handleScroll();
            return true;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: widget.scrollable
                ? null
                : const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.centerTitle
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: allItems,
            ),
          ),
        );
      }
    } else {
      final allItems = [
        ...itemsLeading,
        ...itemsMain,
        ...itemsTrailing,
      ];
      content = SingleChildScrollView(
        controller: _scrollController,
        physics: widget.scrollable
            ? null
            : const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: widget.centerTitle
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: allItems,
        ),
      );
    }

    // Indicator
    Widget? indicator;
    if (_showIndicator && widget.layout == ToolbarLayout.horizontal) {
      indicator = Positioned(
        left: 24,
        right: 24,
        bottom: 4,
        child: rhizu.ProgressIndicator(
          variant: rhizu.ProgressIndicatorVariant.linear,
          value: _scrollProgress,
          shape: rhizu.ProgressIndicatorShape.flat,
          activeColor: effectiveOnBackgroundColor.withValues(alpha: 0.5),
          trackColor: effectiveOnBackgroundColor.withValues(alpha: 0.1),
        ),
      );
    }

    // 4. Container Padding
    final effectivePadding =
        widget.padding ??
        (widget.type == ToolbarType.docked
            ? const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ) // Docked
            : const EdgeInsets.all(12.0)); // Floating

    // 5. Build
    return Material(
      key: const ValueKey('expressive_toolbar_material'),
      color: effectiveBackgroundColor,
      elevation: effectiveElevation,
      shape: effectiveShape,
      child: Stack(
        children: [
          Padding(
            padding: effectivePadding,
            child: IconTheme(
              data: IconThemeData(color: effectiveOnBackgroundColor),
              child: content,
            ),
          ),
          ?indicator,
        ],
      ),
    );
  }
}

// --- Preview ---

@Preview(name: 'Toolbars', size: Size.fromHeight(700))
Widget toolbarPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: ExpressiveToolbarPreview(),
    ),
  );
}

class ExpressiveToolbarPreview extends StatelessWidget {
  const ExpressiveToolbarPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Floating - Standard - Horizontal'),
          const SizedBox(height: 16),
          RZToolbar(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            ],
          ),
          const SizedBox(height: 32),

          const Text('Floating - Vibrant - Horizontal with Split Button'),
          const SizedBox(height: 16),
          RZToolbar(
            style: ToolbarStyle.vibrant,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              const SizedBox(height: 20, child: VerticalDivider()),
              SplitButton(
                label: 'Save',
                leadingIcon: Icons.save,
                onPressed: () {},
                menuBuilder: (ctx) => [
                  const PopupMenuItem<void>(child: Text('Save as...')),
                  const PopupMenuItem<void>(child: Text('Export...')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text('Floating - Standard - Vertical'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              RZToolbar(
                layout: ToolbarLayout.vertical,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.format_bold),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.format_italic),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.format_underline),
                  ),
                ],
              ),
              const SizedBox(width: 30),
              Expanded(
                child: RZToolbar(
                  type: ToolbarType.docked,
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu),
                  ),
                  fab: RZFabMenu(
                    children: [
                      RZFabMenuItem(
                        label: 'Copy',
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedCopy01,
                        ),
                        onPressed: () {},
                      ),
                      RZFabMenuItem(
                        label: 'Paste',
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedFilePaste,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.search),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          const Text('Floating - Vibrant - Mixed Content'),
          const SizedBox(height: 16),
          RZToolbar(
            style: ToolbarStyle.vibrant,
            children: [
              const Text('Selection: 3'),
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
            ],
          ),
        ],
      ),
    );
  }
}
