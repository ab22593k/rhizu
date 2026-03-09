import 'package:flutter/widgets.dart';

class RZNavigationDestination {
  const RZNavigationDestination({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.badge,
  });

  final String label;
  final Widget icon;
  final Widget? selectedIcon;
  final Widget? badge;
}
