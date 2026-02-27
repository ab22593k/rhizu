# M3 Expressive: Adaptive Design Specifications

## Overview
Material 3 Expressive (M3E) evolves adaptive design by moving beyond simple layout shifts to "fluid" adaptation. It focuses on how components and containers scale, morph, and rearrange themselves across a broader range of window size classes.

## Window Size Classes (WSC)
The core foundations for adaptive behavior remain centered on breakpoints, but M3E introduces more granular classes for very large screens.

| Class | Range (dp) | Device Examples | Key Layout Behavior |
| :--- | :--- | :--- | :--- |
| **Compact** | < 600 | Phone, Small Foldable | Single pane, Bottom navigation, Stacked elements. |
| **Medium** | 600 - 840 | Large Foldable, Tablet | Navigation rail, multi-pane potential (Supporting Pane). |
| **Expanded** | 840 - 1200 | Large Tablet, Laptop | Navigation drawer, Side-by-side panes (List-Detail). |
| **Large** | 1200 - 1600 | Desktop, TV | Multi-column, expansive grids, fixed sidebars. |
| **Extra Large** | > 1600 | Ultra-wide Desktop | Optimized wide-screen layouts, density increases. |

## Adaptive Components
M3E components are built to be "flexible" rather than fixed-size.

- **Scaling:** Components like buttons, icons, and text fields now support 5 standard sizes: `XS`, `Small`, `Medium` (default), `Large`, and `XL`.
- **Morphing:** During transitions (e.g., orientation change or window resizing), components can morph shapes (using the new 35-shape library) to fit the new context.
- **Dynamic Density:** On larger screens, the design language favors "contained" content over full-bleed, allowing for better legibility and visual hierarchy.

## Motion & Physics
Adaptive transitions in M3E use **physics-based motion** rather than fixed durations.
- **Natural Springs:** Interactions feel fluid and responsive to the speed of the user's gesture or the system's resize event.
- **Contextual Continuity:** Elements maintain their identity as they move between different layout slots.

## Reference Images/Videos
- **Breakpoints Overview:** [M3 Window Size Classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes)
- **Fluid Adaptation:** [M3 Expressive Motion](https://m3.material.io/styles/motion/overview)
- **Figma Design Kit:** [Material 3 Design Kit V1.20+](https://www.figma.com/community/file/1035203688168086460)
