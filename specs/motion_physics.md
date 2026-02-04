# Material 3 Motion Physics Specs (Flutter)

This document outlines the motion physics system introduced in Material 3 Expressive (May 2025). This physics-based system replaces the legacy easing and duration-based system for a more natural, fluid, and expressive feel.

## Overview

The motion physics system is driven by **Springs**. Unlike the legacy system, springs handle interruptions, gestures, and retargeting seamlessly by preserving velocity.

### Core Concepts

1.  **Motion Schemes**: Define the overall personality of the motion.
    *   **Expressive**: The default scheme. Includes overshoot and bounce for a lively feel.
    *   **Standard**: A more functional scheme with minimal to no bounce.
2.  **Spring Styles**:
    *   **Spatial**: Used for movement (X/Y position), rotation, size, and rounded corners. These allow for overshoot in the Expressive scheme.
    *   **Effects**: Used for color, opacity, and non-spatial properties. These **never** overshoot (damping is always 1.0).
3.  **Speeds**:
    *   **Fast**: For small elements (switches, buttons).
    *   **Default**: For partial-screen animations (bottom sheets, nav drawers).
    *   **Slow**: For full-screen transitions.

---

## Spring Token Specifications

The following values are the default specifications for the **Expressive** motion scheme.

| Token | Damping Ratio | Stiffness | Description |
| :--- | :--- | :--- | :--- |
| **Spring Fast Spatial** | `0.9` | `1400` | Small components like switches and buttons. |
| **Spring Fast Effects** | `1.0` | `3800` | Small component effects like color and opacity. |
| **Spring Default Spatial** | `0.9` | `700` | Partial-screen components (bottom sheets, drawers). |
| **Spring Default Effects** | `1.0` | `1600` | Partial-screen effects. |
| **Spring Slow Spatial** | `0.9` | `300` | Full-screen transitions. |
| **Spring Slow Effects** | `1.0` | `800` | Full-screen animation effects. |

### Implementation Details for Flutter

In Flutter, these values can be applied using `SpringDescription`. Assuming a unit mass (`1.0`):

```dart
// Example: Spring Default Spatial
final springDefaultSpatial = SpringDescription(
  mass: 1.0,
  stiffness: 700.0,
  damping: 0.9 * 2 * sqrt(1.0 * 700.0), // dampingRatio * 2 * sqrt(mass * stiffness)
);
```

*Note: Flutter's `damping` parameter in `SpringDescription` is the absolute damping coefficient, whereas the M3 spec provides a `dampingRatio`. The conversion is: `damping = dampingRatio * 2 * sqrt(mass * stiffness)`.*

---

## Web Conversion (Springs to Curves)

For platforms or contexts where springs cannot be used, the following cubic-bezier curves mimic the motion physics behavior.

| Spring Token | Cubic Bezier | Duration |
| :--- | :--- | :--- |
| **Expressive Fast Spatial** | `0.42, 1.67, 0.21, 0.90` | 350ms |
| **Expressive Default Spatial** | `0.38, 1.21, 0.22, 1.00` | 500ms |
| **Expressive Slow Spatial** | `0.39, 1.29, 0.35, 0.98` | 650ms |
| **Expressive Fast Effects** | `0.31, 0.94, 0.34, 1.00` | 150ms |
| **Expressive Default Effects** | `0.34, 0.80, 0.34, 1.00` | 200ms |
| **Expressive Slow Effects** | `0.34, 0.88, 0.34, 1.00` | 300ms |
| **Standard Fast Spatial** | `0.27, 1.06, 0.18, 1.00` | 350ms |
| **Standard Default Spatial** | `0.27, 1.06, 0.18, 1.00` | 500ms |
| **Standard Slow Spatial** | `0.27, 1.06, 0.18, 1.00` | 750ms |
| **Standard Fast Effects** | `0.31, 0.94, 0.34, 1.00` | 150ms |
| **Standard Default Effects** | `0.34, 0.80, 0.34, 1.00` | 200ms |
| **Standard Slow Effects** | `0.34, 0.88, 0.34, 1.00` | 300ms |

---

## Legacy System (Deprecated)

The following token categories are part of the legacy motion system and are **deprecated** in favor of the Motion Physics system:

*   **Easing Tokens**: `motion.easing.standard`, `motion.easing.emphasized`, etc.
*   **Duration Tokens**: `motion.duration.short1`, `motion.duration.medium2`, etc.
*   **Path Tokens**: All path-based easing tokens.

These should only be used as fallbacks for legacy components that have not yet been migrated to M3 Expressive.
