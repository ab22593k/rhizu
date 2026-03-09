import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rhizu/src/ui/foundation/navigation/destination.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

class RZANavigationShell extends StatelessWidget {
  const RZANavigationShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
    this.floatingActionButton,
  });

  final StatefulNavigationShell navigationShell;
  final List<RZNavigationDestination> destinations;
  final Widget? floatingActionButton;

  void _onNavigate(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final windowClass = WindowSizeClass.fromWidth(
      MediaQuery.sizeOf(context).width,
    );

    // We delegate to expressive, adaptive implementations based on the class.
    return switch (windowClass) {
      WindowSizeClass.compact => _buildCompactNavigation(context),
      WindowSizeClass.medium => _buildMediumNavigation(context, false),
      WindowSizeClass.expanded => _buildMediumNavigation(context, true),
      WindowSizeClass.large => _buildMediumNavigation(context, true),
      WindowSizeClass.extraLarge => _buildMediumNavigation(context, true),
    };
  }

  Widget _buildMediumNavigation(BuildContext context, bool extended) {
    // Expressive adjustments: Width is 80dp/250dp, Container shape uses expressive high-contrast
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            minWidth: 80,
            minExtendedWidth: 250,
            extended: extended,
            destinations: destinations.map((dest) {
              return NavigationRailDestination(
                icon: dest.icon,
                selectedIcon: dest.selectedIcon,
                label: Text(dest.label),
              );
            }).toList(),
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onNavigate,
            leading: floatingActionButton,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }

  Widget _buildCompactNavigation(BuildContext context) {
    final theme = Theme.of(context);
    // Expressive adjustments: Use Label Medium for typography and 80dp height

    return Scaffold(
      body: navigationShell,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        height: 80,
        backgroundColor: theme.colorScheme.surface,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onNavigate,
        destinations: destinations.map((dest) {
          return NavigationDestination(
            icon: dest.icon,
            selectedIcon: dest.selectedIcon,
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }
}
