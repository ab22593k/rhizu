# Circular Progress Indicator (Material 3)

## Overview
Circular progress indicators display progress by animating an indicator along a circular track. The Material 3 update (Dec 2023/2024) introduces gaps and rounded caps, and the M3 Expressive update adds a "Wavy" shape option.

## Specifications (Updated M3 & Expressive)
*Note: To use the updated specs in Flutter, set `year2023: false` in `CircularProgressIndicator` or `ProgressIndicatorThemeData`. For "Wavy" shapes, use Expressive variants.*

### Shapes
1.  **Flat (Standard Circular)**
    - **Shape**: Circular ring.
    - **Stroke Cap**: Rounded caps for the active indicator.
    - **Track Gap**: Visible gap between indicator and track.
    - **Stroke Width**: Standard 4dp.

2.  **Wavy (Expressive)**
    - **Shape**: Wavy circular path (flower-like or gear-like appearance).
    - **Amplitude**: Defines the wave depth/height.
    - **Wavelength**: Defines the frequency of waves around the circle.
    - **Motion**: Waves may rotate or undulate.

## Flutter Implementation
```dart
// Standard M3 (Flat/Circular)
CircularProgressIndicator(
  year2023: false, // Opt-in to new M3 design
  value: 0.5,
  strokeCap: StrokeCap.round,
)

// Wavy (Conceptual - requires Expressive package or custom painter)
// See 'CircularWavyProgressIndicator' in M3 Expressive libraries
```

## Reference Images
- **Visual Configurations (Thickness, Shape - Wavy & Flat):**
  ![Visual Configurations](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c1u61l-01.png?alt=media&token=f27f2cd0-cef6-4afa-ade9-df2dbf14ea0b)

- **Rounded Style & Gap:**
  ![Rounded Style](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c2einw-03.png?alt=media&token=ee7d6244-1b86-4896-85b7-476ce06b10aa)

- **Dynamic Color:**
  ![Dynamic Color](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c2jf26-05.png?alt=media&token=2ee132f7-2c47-46e2-8826-910fbdfe4547)
