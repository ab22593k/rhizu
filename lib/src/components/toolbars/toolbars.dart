import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/src/components/buttons/split_button.dart';
import 'package:rhizu/src/components/indicators/progress.dart' as rhizu;
import 'package:rhizu/src/styles/shapes/tokens.dart';

/// The type of [Toolbar].
enum ToolbarType {
  /// A toolbar docked at the bottom of the screen (replaces BottomAppBar).
  /// Typically full width.
  docked,

  /// A toolbar that floats above content, usually with rounded corners.
  /// Can be horizontal or vertical.
  floating,
}

/// The layout direction of the [Toolbar].
enum ToolbarLayout {
  horizontal,
  vertical,
}

/// The color style of the [Toolbar].
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
class Toolbar extends StatefulWidget {
  const Toolbar({
    required this.children,
    super.key,
    this.type = ToolbarType.floating,
    this.layout = ToolbarLayout.horizontal,
    this.style = ToolbarStyle.standard,
    this.centerTitle = false,
    this.leading,
    this.trailing,
    this.fab,
    this.scrollable = false,
    this.backgroundColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.shape,
  });

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
  final Widget? fab;

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
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
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
    final items = <Widget>[];

    if (widget.leading != null) {
      items.add(widget.leading!);
      items.add(const SizedBox(width: 8, height: 8)); // Gap
    }

    items.addAll(
      widget.children
          .expand((child) => [child, const SizedBox(width: 8, height: 8)])
          .take(widget.children.length * 2 - 1),
    );

    if (widget.trailing != null) {
      items.add(const SizedBox(width: 8, height: 8)); // Gap
      if (widget.type == ToolbarType.docked) {
        items.add(const Spacer());
      }
      items.add(widget.trailing!);
    }

    // FAB Handling
    if (widget.fab != null) {
      items.add(const SizedBox(width: 16, height: 16));
      items.add(widget.fab!);
    }

    // Orientation & Wrapping
    Widget content;
    if (widget.layout == ToolbarLayout.horizontal) {
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
            children: items,
          ),
        ),
      );
    } else {
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
          children: items,
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
        child: rhizu.LinearProgressIndicator(
          value: _scrollProgress,
          size: rhizu.LinearProgressIndicatorSize.s,
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
          Toolbar(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            ],
          ),
          const SizedBox(height: 32),

          const Text('Floating - Vibrant - Horizontal with Split Button'),
          const SizedBox(height: 16),
          Toolbar(
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
              Toolbar(
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
              Toolbar(
                type: ToolbarType.docked,
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
                fab: FloatingActionButton(
                  onPressed: () {},
                  elevation:
                      0, // Docked often has flat FAB or low elevation if inside
                  child: const Icon(Icons.add),
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
            ],
          ),
          const SizedBox(height: 32),

          const Text('Floating - Vibrant - Mixed Content'),
          const SizedBox(height: 16),
          Toolbar(
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
