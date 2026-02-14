import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/src/components/buttons/segmented_button_group.dart'
    as expressive;
import 'package:rhizu/src/components/buttons/split_button.dart';

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
class Toolbar extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 1. Determine Colors
    Color effectiveBackgroundColor;
    Color effectiveOnBackgroundColor;

    if (backgroundColor != null) {
      effectiveBackgroundColor = backgroundColor!;
      effectiveOnBackgroundColor =
          ThemeData.estimateBrightnessForColor(effectiveBackgroundColor) ==
              Brightness.dark
          ? Colors.white
          : Colors.black;
    } else {
      switch (style) {
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
    var effectiveElevation = elevation ?? 0;

    if (type == ToolbarType.docked) {
      // Docked: Rectangular (maybe slight top corners if bottom sheet style, but spec says "docked")
      // M3 Spec: "No shadow" for docked.
      effectiveShape = const RoundedRectangleBorder();
      effectiveElevation = elevation ?? 0.0;
    } else {
      // Floating: High border radius (Stadium or large rounded rect)
      // M3 Spec: "Low elevation"
      effectiveShape = RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(28.0),
      );
      effectiveElevation = elevation ?? 2.0; // Floating default
    }

    // 3. Layout Children
    Widget content;
    final items = <Widget>[];

    if (leading != null) {
      items.add(leading!);
      items.add(const SizedBox(width: 8, height: 8)); // Gap
    }

    items.addAll(
      children
          .expand((child) => [child, const SizedBox(width: 8, height: 8)])
          .take(children.length * 2 - 1),
    );

    if (trailing != null) {
      items.add(const SizedBox(width: 8, height: 8)); // Gap
      items.add(const Spacer()); // Push trailing to end if space allows?
      // Actually, for a flexible toolbar, we might not want Spacer unless it expands.
      // Let's use MainAxisAlignment.spaceBetween if appropriate, or just pack them.
      // For now, let's just append.
      if (type == ToolbarType.docked) {
        // Docked usually has leading...actions...trailing
        // If we want spacer, we should insert it.
        // Let's remove the Spacer from above for generic implementation
        // and handle specific layout logic below.
        items.removeLast(); // Remove Spacer
      }
      items.add(trailing!);
    }

    // FAB Handling
    if (fab != null) {
      items.add(const SizedBox(width: 16, height: 16));
      items.add(fab!);
    }

    // Orientation
    if (layout == ToolbarLayout.horizontal) {
      content = Row(
        mainAxisSize: MainAxisSize.min, // Hug content for floating
        mainAxisAlignment: centerTitle
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: items,
      );
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min, // Hug content
        mainAxisAlignment: centerTitle
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        children: items,
      );
    }

    // Scrolling
    if (scrollable) {
      content = SingleChildScrollView(
        scrollDirection: layout == ToolbarLayout.horizontal
            ? Axis.horizontal
            : Axis.vertical,
        child: content,
      );
    }

    // 4. Container Padding
    final effectivePadding =
        padding ??
        (type == ToolbarType.docked
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
      child: Padding(
        padding: effectivePadding,
        child: IconTheme(
          data: IconThemeData(color: effectiveOnBackgroundColor),
          child: content,
        ),
      ),
    );
  }
}

// --- Preview ---

@Preview(name: 'Expressive Toolbars', size: Size.fromHeight(700))
Widget previewExpressiveToolbar() {
  return const MaterialApp(
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
              const SizedBox(height: 20, child: VerticalDivider()),
              expressive.SegmentedButton<int>(
                selected: const {1},
                onSelectionChanged: (_) {},
                segments: const [
                  ButtonSegment(value: 1, icon: Icon(Icons.list)),
                  ButtonSegment(value: 2, icon: Icon(Icons.grid_view)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
