import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Sizes available for [SegmentedButton] based on Material 3 Expressive specs.
enum SegmentedButtonSize {
  /// Extra Small - 32dp height.
  xs,

  /// Small - 40dp height.
  s,

  /// Medium - 48dp height (Default).
  m,

  /// Large - 56dp height.
  l,

  /// Extra Large - 64dp height.
  xl
  ;

  /// Returns the height for the button size.
  double get height {
    switch (this) {
      case SegmentedButtonSize.xs:
        return 32.0;
      case SegmentedButtonSize.s:
        return 40.0;
      case SegmentedButtonSize.m:
        return 48.0;
      case SegmentedButtonSize.l:
        return 56.0;
      case SegmentedButtonSize.xl:
        return 64.0;
    }
  }

  /// Returns the padding for the button size.
  EdgeInsets get padding {
    switch (this) {
      case SegmentedButtonSize.xs:
        return const EdgeInsets.symmetric(horizontal: 8);
      case SegmentedButtonSize.s:
        return const EdgeInsets.symmetric(horizontal: 12);
      case SegmentedButtonSize.m:
        return const EdgeInsets.symmetric(horizontal: 16);
      case SegmentedButtonSize.l:
        return const EdgeInsets.symmetric(horizontal: 20);
      case SegmentedButtonSize.xl:
        return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  /// Returns the icon size for the button size.
  double get iconSize {
    switch (this) {
      case SegmentedButtonSize.xs:
        return 16.0;
      case SegmentedButtonSize.s:
        return 18.0;
      case SegmentedButtonSize.m:
        return 18.0;
      case SegmentedButtonSize.l:
        return 20.0;
      case SegmentedButtonSize.xl:
        return 22.0;
    }
  }

  /// Returns the text style for the button size.
  TextStyle? textStyle(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (this) {
      case SegmentedButtonSize.xs:
        return textTheme.labelSmall;
      case SegmentedButtonSize.s:
        return textTheme.labelMedium;
      case SegmentedButtonSize.m:
        return textTheme.labelLarge;
      case SegmentedButtonSize.l:
        return textTheme.bodyLarge;
      case SegmentedButtonSize.xl:
        return textTheme.titleMedium;
    }
  }
}

/// A custom implementation of a Segmented Button Group that adheres to
/// Material 3 "Expressive" Connected Button Group specifications.
///
/// Features:
/// - 2dp spacing between segments.
/// - Specific corner radii: Fully rounded outer corners, 8dp inner corners.
/// - 5 Sizes: XS, S, M, L, XL.
/// - Motion: Selection expands width with animation.
class SegmentedButton<T> extends StatelessWidget {
  const SegmentedButton({
    required this.segments,
    required this.selected,
    super.key,
    this.onSelectionChanged,
    this.multiSelectionEnabled = false,
    this.emptySelectionAllowed = false,
    this.style,
    this.showSelectedIcon = true,
    this.selectedIcon,
    this.direction = Axis.horizontal,
    this.size = SegmentedButtonSize.m,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final void Function(Set<T>)? onSelectionChanged;
  final bool multiSelectionEnabled;
  final bool emptySelectionAllowed;
  final ButtonStyle? style;
  final bool showSelectedIcon;
  final Widget? selectedIcon;
  final Axis direction;
  final SegmentedButtonSize size;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final isSelected = selected.contains(segment.value);
      final isFirst = i == 0;
      final isLast = i == segments.length - 1;

      children.add(
        _Segment<T>(
          value: segment.value,
          label: segment.label,
          icon: segment.icon,
          tooltip: segment.tooltip,
          enabled: segment.enabled && onSelectionChanged != null,
          isSelected: isSelected,
          onTap: () => _handleTap(segment.value),
          isFirst: isFirst,
          isLast: isLast,
          size: size,
          showSelectedIcon: showSelectedIcon,
          customSelectedIcon: selectedIcon,
          direction: direction,
        ),
      );

      if (!isLast) {
        children.add(
          direction == Axis.horizontal
              ? const SizedBox(width: 2)
              : const SizedBox(height: 2),
        );
      }
    }

    return direction == Axis.horizontal
        ? Row(mainAxisSize: MainAxisSize.min, children: children)
        : Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  void _handleTap(T value) {
    if (onSelectionChanged == null) return;

    final newSelected = Set<T>.from(selected);
    if (multiSelectionEnabled) {
      if (newSelected.contains(value)) {
        if (emptySelectionAllowed || newSelected.length > 1) {
          newSelected.remove(value);
        }
      } else {
        newSelected.add(value);
      }
    } else {
      if (emptySelectionAllowed && newSelected.contains(value)) {
        newSelected.clear();
      } else {
        newSelected.clear();
        newSelected.add(value);
      }
    }
    onSelectionChanged!(newSelected);
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
    required this.size,
    this.label,
    this.icon,
    this.tooltip,
    this.enabled = true,
    this.showSelectedIcon = true,
    this.customSelectedIcon,
    this.direction = Axis.horizontal,
  });

  final T value;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;
  final SegmentedButtonSize size;
  final Widget? label;
  final Widget? icon;
  final String? tooltip;
  final bool enabled;
  final bool showSelectedIcon;
  final Widget? customSelectedIcon;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Colors based on state
    final backgroundColor = isSelected
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHighest;

    final foregroundColor = isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    final borderSide = BorderSide(
      color: colorScheme.outline,
    );

    // Shape Calculation
    // Inner corners: 8dp
    // Outer corners: Fully rounded (Stadium)
    const innerRadius = 8.0;
    const fullRadius = 999.0;

    BorderRadiusGeometry borderRadius;

    if (direction == Axis.horizontal) {
      // Horizontal logic
      if (isFirst && isLast) {
        borderRadius = BorderRadius.circular(fullRadius);
      } else if (isFirst) {
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(fullRadius),
          bottomLeft: Radius.circular(fullRadius),
          topRight: Radius.circular(innerRadius),
          bottomRight: Radius.circular(innerRadius),
        );
      } else if (isLast) {
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(innerRadius),
          bottomLeft: Radius.circular(innerRadius),
          topRight: Radius.circular(fullRadius),
          bottomRight: Radius.circular(fullRadius),
        );
      } else {
        borderRadius = BorderRadius.circular(innerRadius);
      }
    } else {
      // Vertical logic
      if (isFirst && isLast) {
        borderRadius = BorderRadius.circular(fullRadius);
      } else if (isFirst) {
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(fullRadius),
          topRight: Radius.circular(fullRadius),
          bottomLeft: Radius.circular(innerRadius),
          bottomRight: Radius.circular(innerRadius),
        );
      } else if (isLast) {
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(innerRadius),
          topRight: Radius.circular(innerRadius),
          bottomLeft: Radius.circular(fullRadius),
          bottomRight: Radius.circular(fullRadius),
        );
      } else {
        borderRadius = BorderRadius.circular(innerRadius);
      }
    }

    // Motion parameters
    const duration = Duration(milliseconds: 300);
    const curve = Curves.easeInOutCubicEmphasized;

    // Calculate effective padding for expansion
    final basePadding = size.padding;
    final horizontalExpansion = isSelected ? 12.0 : 0.0;
    final effectivePadding =
        basePadding + EdgeInsets.symmetric(horizontal: horizontalExpansion);

    // Animate the Material color
    // We use TweenAnimationBuilder for the decoration since Material doesn't implicit animate
    return TweenAnimationBuilder<Color?>(
      duration: duration,
      curve: curve,
      tween: ColorTween(begin: backgroundColor, end: backgroundColor),
      builder: (context, color, child) {
        return Material(
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: borderSide,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        );
      },
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: duration,
          curve: curve,
          height: direction == Axis.horizontal ? size.height : null,
          width: direction == Axis.vertical ? null : null,
          constraints: BoxConstraints(
            minWidth: direction == Axis.horizontal ? 48.0 : size.height,
            minHeight: size.height,
          ),
          padding: effectivePadding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animate layout change (icon appearance)
              AnimatedSize(
                duration: duration,
                curve: curve,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected && showSelectedIcon) ...[
                      IconTheme(
                        data: IconThemeData(
                          size: size.iconSize,
                          color: foregroundColor,
                        ),
                        child: customSelectedIcon ?? const Icon(Icons.check),
                      ),
                      if (label != null) const SizedBox(width: 8),
                    ] else if (icon != null) ...[
                      IconTheme(
                        data: IconThemeData(
                          size: size.iconSize,
                          color: foregroundColor,
                        ),
                        child: icon!,
                      ),
                      if (label != null) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              if (label != null)
                DefaultTextStyle(
                  style: (size.textStyle(context) ?? const TextStyle())
                      .copyWith(
                        color: foregroundColor,
                        overflow: TextOverflow.ellipsis,
                      ),
                  child: label!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Previews ---

enum _PreviewChoice { list, grid, map }

@Preview(name: 'SegmentedButton - MultiSelect & IconOnly')
Widget previewSegmentedButtonMultiSelect() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: _SegmentedButtonMultiSelectPreview(),
    ),
  );
}

class _SegmentedButtonMultiSelectPreview extends StatefulWidget {
  const _SegmentedButtonMultiSelectPreview();

  @override
  State<_SegmentedButtonMultiSelectPreview> createState() =>
      _SegmentedButtonMultiSelectPreviewState();
}

class _SegmentedButtonMultiSelectPreviewState
    extends State<_SegmentedButtonMultiSelectPreview> {
  Set<_PreviewChoice> _selected = {_PreviewChoice.list, _PreviewChoice.grid};

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .spaceEvenly,
        children: [
          SegmentedButton<_PreviewChoice>(
            multiSelectionEnabled: true,
            segments: const [
              ButtonSegment(
                value: _PreviewChoice.list,
                label: Text('List'),
                icon: Icon(Icons.list),
              ),
              ButtonSegment(
                value: _PreviewChoice.grid,
                label: Text('Grid'),
                icon: Icon(Icons.grid_view),
              ),
              ButtonSegment(
                value: _PreviewChoice.map,
                label: Text('Map'),
                icon: Icon(Icons.map),
              ),
            ],
            selected: _selected,
            onSelectionChanged: (newSelection) {
              setState(() {
                _selected = newSelection;
              });
            },
          ),
          const _SegmentedButtonIconOnlyPreview(),
        ],
      ),
    );
  }
}

class _SegmentedButtonIconOnlyPreview extends StatefulWidget {
  const _SegmentedButtonIconOnlyPreview();

  @override
  State<_SegmentedButtonIconOnlyPreview> createState() =>
      _SegmentedButtonIconOnlyPreviewState();
}

class _SegmentedButtonIconOnlyPreviewState
    extends State<_SegmentedButtonIconOnlyPreview> {
  _PreviewChoice _selected = _PreviewChoice.list;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SegmentedButton<_PreviewChoice>(
        size: SegmentedButtonSize.s,
        segments: const [
          ButtonSegment(
            value: _PreviewChoice.list,
            icon: Icon(Icons.list),
            tooltip: 'List',
          ),
          ButtonSegment(
            value: _PreviewChoice.grid,
            icon: Icon(Icons.grid_view),
            tooltip: 'Grid',
          ),
          ButtonSegment(
            value: _PreviewChoice.map,
            icon: Icon(Icons.map),
            tooltip: 'Map',
          ),
        ],
        selected: {_selected},
        onSelectionChanged: (newSelection) {
          setState(() {
            _selected = newSelection.first;
          });
        },
      ),
    );
  }
}

@Preview(name: 'SegmentedButton - Common Layouts', size: Size.fromHeight(450))
Widget previewCommonLayouts() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: _CommonLayoutsPreview(),
    ),
  );
}

class _CommonLayoutsPreview extends StatefulWidget {
  const _CommonLayoutsPreview();

  @override
  State<_CommonLayoutsPreview> createState() => _CommonLayoutsPreviewState();
}

class _CommonLayoutsPreviewState extends State<_CommonLayoutsPreview> {
  // State for each group
  _PreviewChoice _selectedLabel = _PreviewChoice.list;
  _PreviewChoice _selectedLabelIcon = _PreviewChoice.list;
  _PreviewChoice _selectedIconXS = _PreviewChoice.list;
  _PreviewChoice _selectedIconL = _PreviewChoice.list;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Label buttons',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<_PreviewChoice>(
              segments: const [
                ButtonSegment(
                  value: _PreviewChoice.list,
                  label: Text('List'),
                ),
                ButtonSegment(
                  value: _PreviewChoice.grid,
                  label: Text('Grid'),
                ),
                ButtonSegment(value: _PreviewChoice.map, label: Text('Map')),
              ],
              selected: {_selectedLabel},
              onSelectionChanged: (val) =>
                  setState(() => _selectedLabel = val.first),
            ),
            const SizedBox(height: 24),

            Text(
              'Label and icon buttons',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<_PreviewChoice>(
              segments: const [
                ButtonSegment(
                  value: _PreviewChoice.list,
                  label: Text('List'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: _PreviewChoice.grid,
                  label: Text('Grid'),
                  icon: Icon(Icons.grid_view),
                ),
                ButtonSegment(
                  value: _PreviewChoice.map,
                  label: Text('Map'),
                  icon: Icon(Icons.map),
                ),
              ],
              selected: {_selectedLabelIcon},
              onSelectionChanged: (val) =>
                  setState(() => _selectedLabelIcon = val.first),
            ),
            const SizedBox(height: 24),

            Text(
              'Extra small icon buttons',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<_PreviewChoice>(
              size: SegmentedButtonSize.xs,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _PreviewChoice.list,
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: _PreviewChoice.grid,
                  icon: Icon(Icons.grid_view),
                ),
                ButtonSegment(
                  value: _PreviewChoice.map,
                  icon: Icon(Icons.map),
                ),
              ],
              selected: {_selectedIconXS},
              onSelectionChanged: (val) =>
                  setState(() => _selectedIconXS = val.first),
            ),
            const SizedBox(height: 24),

            Text(
              'Large icon buttons',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<_PreviewChoice>(
              size: SegmentedButtonSize.l,
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _PreviewChoice.list,
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: _PreviewChoice.grid,
                  icon: Icon(Icons.grid_view),
                ),
                ButtonSegment(
                  value: _PreviewChoice.map,
                  icon: Icon(Icons.map),
                ),
              ],
              selected: {_selectedIconL},
              onSelectionChanged: (val) =>
                  setState(() => _selectedIconL = val.first),
            ),
          ],
        ),
      ),
    );
  }
}
