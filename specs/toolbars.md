# Material 3 Expressive Toolbars - UI/UX Specifications

> Source: https://m3.material.io/components/toolbars/overview
> Last Updated: 2026-02-14

## Overview

Toolbars display frequently used actions relevant to the current page. Material 3 Expressive introduces two new toolbar types to replace the legacy bottom app bar.

## Key Features

- Two expressive types: **docked toolbar** and **floating toolbar**
- Use the vibrant color style for greater emphasis
- Can display a wide variety of control types, like buttons, icon buttons, and text fields
- Can be paired with FABs to emphasize certain actions
- Don't show at the same time as a navigation bar

---

## Toolbar Types

### 1. Docked Toolbar

Replaces the legacy **bottom app bar**. Functions similarly but with improvements:

**Characteristics:**
- **Size:** Shorter height than M2 bottom app bar
- **Color:** Standard or vibrant color schemes
- **Flexibility:** More layout and element options
- **Elevation:** No shadow (elevation removed)
- **FAB Integration:** FAB is now contained within the toolbar container

**When to use:**
- For persistent navigation and actions at the bottom of the screen
- When you need a fixed anchor for primary actions

### 2. Floating Toolbar

New versatile toolbar type with greater flexibility:

**Characteristics:**
- **Layout:** Horizontal or vertical orientations
- **Color:** Standard or vibrant color schemes
- **Flexibility:** Can hold many elements and components
- **FAB Pairing:** Can be paired with FAB for emphasized actions
- **Placement:** More variety in positioning options

**Configurations:**
- Can be placed in various locations (not just bottom)
- Supports both horizontal and vertical layouts
- Greater amounts of actions can be displayed

---

## Layout Variants

### Horizontal Toolbar
- Actions arranged side by side
- Best for 2-5 actions
- Can include text fields, buttons, icon buttons

### Vertical Toolbar
- Actions stacked vertically
- Best for menus or many actions
- Floating toolbar only

---

## Color Styles

### Standard Color
- Uses surface container colors
- Subtle appearance
- Default choice for most contexts

### Vibrant Color
- Uses primary or secondary color containers
- Greater emphasis
- Use for high-priority actions or featured content

---

## Dimensions & Specifications

### Docked Toolbar
- **Height:** Shorter than M2 bottom app bar (exact height TBD from Figma kit)
- **Container:** Extended to contain FAB
- **Padding:** Standard Material 3 spacing
- **No elevation:** Flat appearance, no shadow

### Floating Toolbar
- **Layout:** Flexible dimensions based on content
- **Horizontal:** Width adapts to content
- **Vertical:** Height adapts to content
- **Corner radius:** Material 3 expressive radius tokens
- **Elevation:** Low elevation for floating appearance

---

## Component Anatomy

### Docked Toolbar Parts:
1. **Container** - The toolbar background
2. **Navigation Icon** (optional) - Menu or back button
3. **Title/Label** (optional) - Context description
4. **Action Icons** - Primary actions
5. **FAB Container** - Embedded floating action button
6. **Overflow Menu** - Additional actions

### Floating Toolbar Parts:
1. **Container** - The floating panel
2. **Leading Actions** - Primary or frequent actions
3. **Separator** (optional) - Between action groups
4. **Trailing Actions** - Secondary actions
5. **Text Field** (optional) - Search or input

---

## States

### Default State
- Normal appearance with standard colors

### Pressed/Selected State
- Visual feedback for active items
- Ripple effect

### Disabled State
- Reduced opacity for unavailable actions

### Scrolled State (Docked)
- May hide or transform on scroll
- Optional hide-on-scroll behavior

---

## Design Images

### Type Examples

**Toolbar Types Overview:**
![2 types of toolbars](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aionfm-01.png?alt=media&token=0f1d71f5-1d22-4820-859d-fd952e995cf9)

*Caption: Configurations of floating toolbars*

**Toolbar Type Examples:**
![2 examples of toolbar types](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aiswog-02.png?alt=media&token=e5523e45-647f-4168-b257-c773be63adf6)

1. Floating, vibrant color scheme and paired with FAB
2. Docked with embedded primary action instead of FAB

### M2 vs M3 Comparison

**M2 Bottom App Bar:**
![M2 bottom app bar](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0e7liab-2.png?alt=media&token=16c3ad53-7e83-4079-85ad-9b096bbb56fc)

*M2: Bottom app bar had higher elevation of 8dp and didn't contain the FAB*

**M3 Bottom App Bar (Legacy):**
![M3 bottom app bar](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0e7mh6v-3.png?alt=media&token=9dfb6612-f40c-4d4c-a773-463109db7c5f)

*M3: Bottom app bar has new colors, a taller container, no elevation or shadow, and contains the FAB*

---

## Differences from Material 2

| Feature | M2 Bottom App Bar | M3 Docked Toolbar | M3 Floating Toolbar |
|---------|------------------|-------------------|---------------------|
| Height | Standard | Shorter | Flexible |
| Elevation | 8dp shadow | No shadow | Low elevation |
| FAB Position | Cutout/overlap | Contained within | Can be paired |
| Layout | Fixed bottom | Fixed bottom | Flexible placement |
| Color | Fixed scheme | Standard/Vibrant | Standard/Vibrant |
| Dynamic Color | No | Yes | Yes |

---

## Implementation Resources

### Flutter
- **BottomAppBar:** https://api.flutter.dev/flutter/material/BottomAppBar-class.html
- Status: Available

### Android
- **Jetpack Compose:** https://developer.android.com/develop/ui/compose/components/app-bars#bottom
- **Jetpack Compose Expressive:** Available
- **MDC-Android:** https://github.com/material-components/material-components-android/blob/master/docs/components/BottomAppBar.md
- **MDC-Android Expressive:** Available

### Web
- Status: Unavailable
- Expressive: Unavailable

### Design Kit
- **Figma:** https://www.figma.com/community/file/1035203688168086460

---

## Usage Guidelines

### Do's
- Use docked toolbar for persistent bottom navigation
- Use floating toolbar for contextual or secondary actions
- Pair floating toolbar with FAB for emphasized primary actions
- Use vibrant color for featured or high-priority toolbars
- Limit docked toolbar actions to 3-5 items
- Include overflow menu for additional actions

### Don'ts
- Don't show toolbar at the same time as a navigation bar
- Don't use M2 bottom app bar for new designs (deprecated)
- Don't overload toolbar with too many actions
- Don't use floating toolbar as primary navigation

---

## Related Components

- **FAB (Floating Action Button)** - Often paired with toolbars
- **Icon Buttons** - Common toolbar actions
- **Text Fields** - Can be embedded in floating toolbars
- **Menus** - For overflow actions
- **Navigation Bar** - Alternative to docked toolbar (don't use together)

---

## Accessibility Considerations

- Ensure sufficient touch targets (minimum 48dp)
- Provide content descriptions for icon buttons
- Maintain color contrast ratios (WCAG 4.5:1)
- Support screen reader navigation
- Consider keyboard navigation for desktop

---

## References

- Material 3 Toolbars Overview: https://m3.material.io/components/toolbars/overview
- Material 3 Toolbars Specs: https://m3.material.io/components/toolbars/specs
- Material 3 Toolbars Guidelines: https://m3.material.io/components/toolbars/guidelines
- M3 Expressive Blog: https://m3.material.io/blog/building-with-m3-expressive
