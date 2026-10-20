import 'package:flutter/widgets.dart';

/// A single item of a `ButtonGroup`.
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
