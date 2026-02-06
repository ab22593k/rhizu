# Linear Progress Indicator (Material 3)

## Overview
Linear progress indicators display progress by animating an indicator along the length of a fixed, visible track. The Material 3 update (Dec 2023/2024) introduces a more distinct visual style with gaps and rounded shapes, and the M3 Expressive update adds a "Wavy" shape option.

## Specifications (Updated M3 & Expressive)
*Note: To use the updated specs in Flutter, set `year2023: false` in `LinearProgressIndicator` or `ProgressIndicatorThemeData`. For "Wavy" shapes, you may need to use Expressive variants or custom implementations if not yet standard in the main widget.*

### Shapes
1.  **Flat (Standard Linear)**
    - **Shape**: Rounded corners (Capsule) for both track and indicator.
    - **Track Height**: 4dp (Standard).
    - **Track Gap**: 4dp (Standard gap between indicator and track).
    - **Stop Indicator**: Visible in determinate mode.

2.  **Wavy (Expressive)**
    - **Shape**: Wavy path for both track and indicator.
    - **Track Height**: 
        - Standard: ~4-10dp (varies by amplitude).
        - Thick: 8dp stroke width (approx 14dp container height).
    - **Amplitude**: Defines the wave height (0.0 to 1.0, where 1.0 is full height).
    - **Wavelength**: Distance between adjacent peaks (Standard: ~48dp or matched to speed).
    - **Wave Speed**: Animated movement of the wave (Standard: 1 wavelength/sec).

## Flutter Implementation
```dart
// Standard M3 (Flat/Capsule)
LinearProgressIndicator(
  year2023: false, // Opt-in to new M3 design
  value: 0.5,
  borderRadius: BorderRadius.circular(4), // Ensure rounded corners
)

// Wavy (Conceptual - requires Expressive package or custom painter)
// See 'LinearWavyProgressIndicator' in M3 Expressive libraries
```

## Reference Images
- **Visual Configurations (Thickness, Shape - Wavy & Flat):**
  ![Visual Configurations](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c1u61l-01.png?alt=media&token=f27f2cd0-cef6-4afa-ade9-df2dbf14ea0b)

- **Rounded Style & Gap:**
  ![Rounded Style](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c2einw-03.png?alt=media&token=ee7d6244-1b86-4896-85b7-476ce06b10aa)

- **Dynamic Color:**
  ![Dynamic Color](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c2jf26-05.png?alt=media&token=2ee132f7-2c47-46e2-8826-910fbdfe4547)
