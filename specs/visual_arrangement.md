# M3 Expressive: Visual Arrangement & Tactics

## Overview
Expressive design prioritizes "emotion-driven" UX. It uses visual arrangement to guide users through hierarchy and "Hero Moments."

## Design Tactics
Tactics for arranging elements to create engagement and usability:

1. **Variety of Shapes**
   - Use the **Material Shape Library** (35+ shapes).
   - Mix corner radii (e.g., sharp corners for static containers, highly rounded for interactive ones) to establish a visual vocabulary.
   - **Tokens:** Corner radii are now tokenized (e.g., `md.sys.shape.corner.extra-large`).

2. **Grouped Containers**
   - Components are logically grouped into "containers" that dynamically adapt space.
   - **Strategic Symmetry:** Use balance for calmness, or break symmetry to draw attention to a primary action (e.g., a split-button or FAB menu).

3. **Typography Hierarchy**
   - **Display & Headline:** Use larger, more expressive weights for titles to create a strong entry point.
   - **Body & Label:** Maintain strict readability while allowing the surrounding "expressive" elements (shapes/color) to provide context.

4. **Hero Moments**
   - A "Hero Moment" is a specific combination of large-scale typography, unique shapes, and motion used to celebrate user success or highlight the primary task.

## Spacing & Alignment
- **Dynamic Margins:** Margins should grow with the Window Size Class (e.g., 16dp for Compact, 24dp for Medium, 32dp+ for Expanded).
- **Alignment:** Focus on "Containment." Centering content in large screens prevents the user's eye from having to travel too far across the display.

## Reference Images/Videos
- **Expressive Tactics:** [Applying M3 Expressive](https://m3.material.io/foundations/usability/applying-m-3-expressive)
- **Shape System:** [M3 Shape Guidelines](https://m3.material.io/styles/shape/overview)
- **Motion Principles:** [M3 Motion Physics](https://m3.material.io/styles/motion/overview/how-it-works)
