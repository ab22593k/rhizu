import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rhizu/src/ui/foundation/navigation/adaptive_navigation_shell.dart';
import 'package:rhizu/src/ui/foundation/navigation/destination.dart';
import 'package:rhizu/src/ui/foundation/window_size_class.dart';

void main() {
  group('RZAdaptiveNavigationShell', () {
    testWidgets('renders NavigationBar when WindowSizeClass is compact', (
      tester,
    ) async {
      await _pumpRouter(tester, WindowSizeClass.compact);

      // In compact mode, a Bottom Navigation Bar should be rendered.
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('renders NavigationRail when WindowSizeClass is medium', (
      tester,
    ) async {
      await _pumpRouter(tester, WindowSizeClass.medium);

      // In medium mode, a Rail should be rendered.
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationDrawer), findsNothing);
    });

    testWidgets(
      'renders extended NavigationRail when WindowSizeClass is expanded',
      (tester) async {
        await _pumpRouter(tester, WindowSizeClass.expanded);

        // In expanded mode, an extended Rail should be rendered.
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(NavigationDrawer), findsNothing);

        final rail = tester.widget<NavigationRail>(find.byType(NavigationRail));
        expect(rail.extended, isTrue);
      },
    );
  });
}

Future<void> _pumpRouter(
  WidgetTester tester,
  WindowSizeClass windowSizeClass,
) async {
  final router = GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Provide our adaptive shell
          return RZAdaptiveNavigationShell(
            navigationShell: navigationShell,
            destinations: const [
              RZNavigationDestination(
                label: 'A',
                icon: Icon(Icons.home),
              ),
              RZNavigationDestination(
                label: 'B',
                icon: Icon(Icons.search),
              ),
            ],
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/a',
                builder: (context, state) => const Text('Screen A'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/b',
                builder: (context, state) => const Text('Screen B'),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      builder: (context, child) {
        // Force the window size class we want to test by mocking MediaQuery
        final width = switch (windowSizeClass) {
          WindowSizeClass.compact => 400.0,
          WindowSizeClass.medium => 700.0,
          WindowSizeClass.expanded => 1000.0,
          WindowSizeClass.large => 1400.0,
          WindowSizeClass.extraLarge => 1800.0,
        };

        return MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    ),
  );
  await tester.pumpAndSettle();
}
