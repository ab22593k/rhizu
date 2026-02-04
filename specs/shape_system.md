# Material 3 Shape System Specs (Flutter)

This document outlines the Material 3 shape system, including the refined corner radius scale and the Expressive shape library (introduced May 2025). This system provides a unified way to apply shape to components, improving visual hierarchy and brand expression.

## Overview

The M3 shape system defines how corners are rounded and how custom shapes are applied to UI elements. It uses a token-based scale for corner radii and a library of 35 expressive shapes for more decorative or brand-focused moments.

### Core Concepts

1.  **Shape Scale**: A set of tokens that define corner roundedness, ranging from `None` to `Full`.
2.  **Symmetry**: While most components use symmetrical shapes, the system supports asymmetrical corners for specific design needs.
3.  **Expressive Shapes**: A collection of 35 unique shapes used for imagery, avatars, and decorative UI elements. These are intended to be used with motion (shape morphing).

---

## Corner Radius Scale

The following tokens represent the standard corner radius values for Material 3. These values should be applied consistently across the application.

| Token | Radius (dp) | Typical Use Case |
| :--- | :--- | :--- |
| **None** | `0.0` | Sharp corners, full-screen containers. |
| **Extra Small** | `4.0` | Small components like snackbars or tooltips. |
| **Small** | `8.0` | Chips, text fields, and smaller buttons. |
| **Medium** | `12.0` | Cards, menus, and floating action buttons (FABs). |
| **Large** | `16.0` | Large cards, dialogs, and navigation drawers. |
| **Large Increased** | `20.0` | Prominent containers requiring more emphasis. |
| **Extra Large** | `28.0` | Large modal sheets and prominent surfaces. |
| **Extra Large Increased** | `32.0` | Expressive large components. |
| **Extra Extra Large** | `48.0` | Very large surfaces or decorative backdrops. |
| **Full** | `Full` | Circular or stadium-shaped components (e.g., Pill). |

*Note: The "Full" token automatically calculates the radius to be 50% of the component's smallest dimension (creating a stadium or circle).*

---

## Expressive Shape Library

Material 3 Expressive includes a set of 35 shapes. In this project, these shapes are available as SVG assets in `@assets/shapes/`.

| Shape Name | Asset Path |
| :--- | :--- |
| **Arch** | `assets/shapes/material_shape_arch.svg` |
| **Arrow** | `assets/shapes/material_shape_arrow.svg` |
| **Boom** | `assets/shapes/material_shape_boom.svg` |
| **Bun** | `assets/shapes/material_shape_bun.svg` |
| **Burst** | `assets/shapes/material_shape_burst.svg` |
| **Circle** | `assets/shapes/material_shape_circle.svg` |
| **Clover 4** | `assets/shapes/material_shape_clover_4.svg` |
| **Clover 8** | `assets/shapes/material_shape_clover_8.svg` |
| **Cookie 12** | `assets/shapes/material_shape_cookie_12.svg` |
| **Cookie 4** | `assets/shapes/material_shape_cookie_4.svg` |
| **Cookie 6** | `assets/shapes/material_shape_cookie_6.svg` |
| **Cookie 7** | `assets/shapes/material_shape_cookie_7.svg` |
| **Cookie 9** | `assets/shapes/material_shape_cookie_9.svg` |
| **Diamond** | `assets/shapes/material_shape_diamond.svg` |
| **Fan** | `assets/shapes/material_shape_fan.svg` |
| **Flower** | `assets/shapes/material_shape_flower.svg` |
| **Gem** | `assets/shapes/material_shape_gem.svg` |
| **Ghostish** | `assets/shapes/material_shape_ghostish.svg` |
| **Heart** | `assets/shapes/material_shape_heart.svg` |
| **Hexagon** | `assets/shapes/material_shape_hexagon.svg` |
| **Oval** | `assets/shapes/material_shape_oval.svg` |
| **Pentagon** | `assets/shapes/material_shape_pentagon.svg` |
| **Pill** | `assets/shapes/material_shape_pill.svg` |
| **Pixel Circle** | `assets/shapes/material_shape_pixel_circle.svg` |
| **Pixel Triangle** | `assets/shapes/material_shape_pixel_triangle.svg` |
| **Puffy** | `assets/shapes/material_shape_puffy.svg` |
| **Puffy Diamond** | `assets/shapes/material_shape_puffy_diamond.svg` |
| **Semicircle** | `assets/shapes/material_shape_semicircle.svg` |
| **Slanted Square** | `assets/shapes/material_shape_slanted_square.svg` |
| **Soft Boom** | `assets/shapes/material_shape_soft_boom.svg` |
| **Soft Burst** | `assets/shapes/material_shape_soft_burst.svg` |
| **Square** | `assets/shapes/material_shape_square.svg` |
| **Sunny** | `assets/shapes/material_shape_sunny.svg` |
| **Triangle** | `assets/shapes/material_shape_triangle.svg` |
| **Very Sunny** | `assets/shapes/material_shape_very_sunny.svg` |

---

## Implementation Details for Flutter

### Using Corner Radii

Apply corner radii using `BorderRadius.circular()` or `RoundedRectangleBorder`.

```dart
// Example: Medium Radius (12.0)
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ),
  child: ...,
)

// Example: Full Radius (Stadium shape)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: const StadiumBorder(),
  ),
  onPressed: () {},
  child: const Text('Action'),
)
```

### Using Expressive Shapes

For custom shapes from the asset library, use `ClipPath` with a custom clipper or an SVG masking approach.

```dart
// Example: Using an SVG shape as a mask
Widget buildShape(BuildContext context) {
  return SvgPicture.asset(
    'assets/shapes/material_shape_flower.svg',
    colorFilter: ColorFilter.mode(Colors.primary, BlendMode.srcIn),
  );
}
```

---

## Deprecated & Legacy Shapes

The following categories are **excluded** from the modern M3 shape system and should be avoided:

*   **Fixed Percentage Rounding**: Rounding defined as `50%` of component size should be replaced by the `Full` token logic.
*   **Material 2 Defaults**: Avoid the generic `4.0dp` rounding previously used for almost all components. Use the specific M3 token assigned to the component type.
