# Loading Indicator Specs

**Status**: Experimental (Material 3 Expressive)
**Usage**: Short wait times (200ms - 5s).
**Description**: Loading indicators use animation to grab attention, mitigate perceived latency, and indicate that an activity is in progress. They replace the indeterminate Circular Progress Indicator for short processes.

## Dimensions

| Parameter | Value |
| :--- | :--- |
| **Container Width** | 48dp |
| **Container Height** | 48dp |
| **Active Indicator Size** | 38dp |
| **Active Indicator Scale** | ~0.79 (38/48) |
| **Shape** | Full Corner (Circle/Rounded) |

## Colors

### Uncontained
*   **Indicator**: `ColorScheme.primary`

### Contained
*   **Container**: `ColorScheme.primaryContainer`
*   **Indicator**: `ColorScheme.onPrimaryContainer`

## Indeterminate Animation Sequence

The indeterminate loading indicator morphs between a sequence of 7 shapes in a loop.

**Shape Sequence:**
1.  `material_shape_soft_burst`
2.  `material_shape_cookie_9`
3.  `material_shape_pentagon`
4.  `material_shape_pill`
5.  `material_shape_sunny`
6.  `material_shape_cookie_4`
7.  `material_shape_oval`

**Loop**: The sequence is circular (morphs from last shape back to first).

## Animation Physics & Timing

*   **Morph Interval**: 650ms per shape transition.
*   **Global Rotation**: 360° rotation every 4666ms (Linear).
*   **Step Rotation**: +90° rotation increment per morph step.
*   **Morph Animation Spec**:
    *   **Type**: Spring
    *   **Damping Ratio**: 0.6
    *   **Stiffness**: 200.0
    *   **Visibility Threshold**: 0.1

## Behavior

*   **Morphing**: The indicator morphs from one shape to the next.
*   **Rotation**: The entire indicator rotates linearly while also stepping its rotation by 90 degrees at each morph completion.
*   **Scaling**: The shapes are scaled to fit within the 38dp active area, maintaining their aspect ratio.
