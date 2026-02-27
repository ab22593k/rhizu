import 'package:flutter/material.dart';

/// Internal navigation item for toolbars in foundations.
class FoundationNavigationItem extends StatelessWidget {
  const FoundationNavigationItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final NavigationDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: (isSelected ? destination.selectedIcon : null) ?? destination.icon,
      tooltip: destination.label,
      color: isSelected ? Theme.of(context).colorScheme.primary : null,
    );
  }
}

/// Helper to merge navigation items and action children into a single list.
List<Widget> mergeNavAndActions(
  List<NavigationDestination>? destinations,
  int? selectedIndex,
  ValueChanged<int>? onDestinationSelected,
  List<Widget>? actions,
) {
  final items = <Widget>[];
  if (destinations != null) {
    for (var i = 0; i < destinations.length; i++) {
      items.add(
        FoundationNavigationItem(
          destination: destinations[i],
          isSelected: selectedIndex == i,
          onTap: () => onDestinationSelected?.call(i),
        ),
      );
    }
  }

  if (actions != null && actions.isNotEmpty) {
    if (items.isNotEmpty) {
      items.add(const SizedBox(height: 24, child: VerticalDivider(width: 24)));
    }
    items.addAll(actions);
  }

  return items;
}
