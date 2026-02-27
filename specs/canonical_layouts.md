# M3 Expressive: Canonical Layouts (Flutter Specs)

## Overview
Canonical layouts are standard starting points for common app structures. They are designed to adapt seamlessly across all Material 3 Window Size Classes.

## The Three Standard Layouts

### 1. List-Detail
- **Purpose:** Browsing a collection and viewing item details simultaneously.
- **Behavior:**
  - **Compact:** Shows the List or Detail view (modal-like transition).
  - **Expanded:** Displays both panes side-by-side.
- **Reference Image:** [List-Detail Overview](https://m3.material.io/foundations/layout/canonical-layouts/list-detail)

### 2. Supporting Pane
- **Purpose:** Productivity and multitasking. The primary content stays in focus while a secondary pane provides tools or metadata.
- **Behavior:**
  - **Compact:** Supporting pane is usually hidden in a bottom sheet or separate screen.
  - **Medium/Expanded:** Supporting pane docks to the side (right or left).
- **Reference Image:** [Supporting Pane Overview](https://m3.material.io/foundations/layout/canonical-layouts/supporting-pane)

### 3. Feed
- **Purpose:** Content consumption (news, social, commerce).
- **Behavior:**
  - **Compact:** Single column of cards.
  - **Expanded:** Multi-column grid that optimizes whitespace.
- **Reference Image:** [Feed Overview](https://m3.material.io/foundations/layout/canonical-layouts/feed)

## Flutter Implementation (`flutter_adaptive_scaffold`)
The recommended way to implement these in Flutter is using the official adaptive library.

### Core Widgets:
- **`AdaptiveScaffold`:** Handles the high-level transitions between Bottom Navigation (Compact) and Navigation Rails/Drawers (Medium/Expanded).
- **`AdaptiveLayout`:** A lower-level widget providing slots for:
  - `primaryNavigation`
  - `topNavigation`
  - `body`
  - `secondaryBody`
- **`SlotLayout`:** Defines what content goes into a slot based on a `Breakpoint`.

### Example Code Snippet:
```dart
AdaptiveScaffold(
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
  ],
  body: (context) => const MainContent(),
  secondaryBody: (context) => const SupportingContent(),
)
```

## Reference Images/Videos
- **Canonical Overview:** [M3 Canonical Layouts](https://m3.material.io/foundations/layout/canonical-layouts/overview)
- **Flutter Adaptive Library:** [Google I/O 2024 Session](https://io.google/2024/explore/2dff9b4c-4069-4bde-ab9a-c5f53dc0fdb8/)
- **Jetpack Compose Adaptive:** [Adaptive UI Guidelines](https://developer.android.com/develop/ui/compose/layouts/adaptive)
