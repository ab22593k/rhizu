import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/buttons/split_button_item.dart';

/// The menu shown by `SplitButton` in its overlay.
class SplitButtonMenu<T> extends StatelessWidget {
  const SplitButtonMenu({
    required this.items,
    required this.menuBuilder,
    required this.onDismiss,
    required this.onSelected,
    super.key,
  });

  /// The declarative menu items. When `null`, [menuBuilder] is used instead.
  final List<SplitButtonItem<T>>? items;

  /// A builder for custom popup-menu entries.
  final List<PopupMenuEntry<T>> Function(BuildContext)? menuBuilder;

  /// Called before a selection is reported, so the menu can close.
  final VoidCallback onDismiss;

  /// Called with the selected value.
  final ValueChanged<T>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children:
            items?.map((item) {
              return ListTile(
                title: item.child is Widget
                    ? (item.child as Widget)
                    : Text(item.child.toString()),
                enabled: item.enabled,
                onTap: () {
                  onDismiss();
                  onSelected?.call(item.value);
                },
              );
            }).toList() ??
            menuBuilder!(context),
      ),
    );
  }
}
