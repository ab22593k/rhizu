# Material 3 Elevation System (Expressive Update)

## Overview
Elevation in Material 3 (M3) represents the distance between two surfaces along the z-axis. In the latest "Expressive" update (May 2025), the system has moved away from dynamic color overlays (Surface Tints) in favor of a fixed scale of elevation levels and specific surface container roles.

## Elevation Levels & Tokens

| Level | DP Height | Token | Typical Component Usage |
| :--- | :--- | :--- | :--- |
| **Level 0** | 0dp | `elevation.level0` | Resting: Filled/Outlined Buttons, Standard Cards, Tabs |
| **Level 1** | 1dp | `elevation.level1` | Resting: Elevated Buttons, Elevated Cards, Elevated Chips |
| **Level 2** | 3dp | `elevation.level2` | Scrolled: App Bars, Menus, Navigation Bars |
| **Level 3** | 6dp | `elevation.level3` | Resting: FABs, Dialogs, Search, Pickers |
| **Level 4** | 8dp | `elevation.level4` | State: Hovered/Focused Level 3 components |
| **Level 5** | 12dp | `elevation.level5` | State: Dragged components |

## Deprecation Notice: Surface Tint
**Status: Deprecated**
The previous M3 approach of using a `surfaceTint` color (a percentage of the Primary color overlaid on the Surface color) is deprecated. 

**Current Standard:**
Developers should use the **Surface Container** color roles to distinguish hierarchy. Elevation levels should primarily control **Shadows** (if enabled) and **Z-index** for layering, while the background color remains tied to its specific role:
- `surfaceContainerLowest`
- `surfaceContainerLow`
- `surfaceContainer`
- `surfaceContainerHigh`
- `surfaceContainerHighest`

## Shadow Specifications
Shadows in M3 are softer and more diffused than in M2.
- **Low Elevation (1-2)**: Sharp, subtle shadows or purely tonal separation.
- **High Elevation (3-5)**: Larger, diffused shadows to indicate significant distance and focus.

## Scrim
- **Role**: `colorScheme.scrim`
- **Opacity**: 32%
- **Usage**: Mandatory for modal dialogs and bottom sheets to isolate the component from the background content.

## Implementation Notes (Flutter)
- Use `Material` or `PhysicalModel` widgets for custom surfaces.
- In `ThemeData`, ensure `useMaterial3: true` is set.
- Access elevation levels via `Theme.of(context).elevationTheme` (if implemented) or manually using the DP values above.
