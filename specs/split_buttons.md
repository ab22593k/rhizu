# Material 3 Expressive Split Button - Flutter Specifications

## Overview

Split buttons are two-segment controls that combine a primary action with a related secondary action (typically a dropdown menu). The leading segment performs the primary action, while the trailing segment opens a menu with additional related options.

**Key Characteristics:**
- Two-segment control: Leading (primary action) + Trailing (menu trigger)
- Contextually related actions in a compact format
- Supports 5 sizes: XS, S, M, L, XL
- Two shape variants: Round and Square
- Five emphasis levels: Filled, Tonal, Elevated, Outlined, Text
- Optical centering and morphing animations
- Full accessibility support

---

## Visual Assets & Reference Images

### Split Button Anatomy
![Split Button Overview](https://pub.dev/static/hash-4ut0obnn/img/pub-dev-icon-cover-image.png)
*Material 3 Expressive Split Button with sizes, variants, shapes, a11y, and menu*

### Split Button Structure
- **Leading Segment**: Primary action (icon, label, or both)
- **Trailing Segment**: Menu trigger with chevron icon
- **Inner Gap**: Fixed 2dp spacing between segments
- **Menu**: Opens aligned to trailing edge

### Size Variants Preview
The component supports 5 distinct sizes with specific dimensions:
- XS: 32dp height (Extra Small)
- S: 40dp height (Small) 
- M: 56dp height (Medium - Default)
- L: 96dp height (Large)
- XL: 136dp height (Extra Large)

### Shape Morphing Animation
When shape is `round` and size is M/L/XL, the trailing segment morphs into a perfect circle (diameter = control height) when pressed or menu is open.

---

## M3 Expressive Specifications

### Size Tokens

| Size | Height | Trailing Width | Icon Size | Inner Corner Radius |
|------|--------|----------------|-----------|---------------------|
| XS | 32dp | 22dp | 20dp | 4dp |
| S | 40dp | 22dp | 24dp | 4dp |
| M | 56dp | 26dp | 24dp | 4dp |
| L | 96dp | 38dp | 32dp | 8dp |
| XL | 136dp | 50dp | 40dp | 12dp |

### Spacing Tokens

| Element | Value |
|---------|-------|
| Inner gap (between segments) | 2dp |
| Minimum touch target | 48×48dp |

### Optical Chevron Offset (Unselected/Resting State)

| Size | Offset |
|------|--------|
| XS | -1dp |
| S | -1dp |
| M | -2dp |
| L | -3dp |
| XL | -6dp |

### Asymmetrical Paddings (Unselected State)

**XS Size:**
- Leading icon block: 20dp
- Left outer padding: 12dp
- Gap icon→label: 4dp
- Label right padding: 10dp
- Trailing left inner: 12dp
- Right outer: 14dp

**S Size:**
- Leading icon block: 20dp
- Left outer: 16dp
- Gap: 8dp
- Label right: 12dp
- Trailing left inner: 12dp
- Right outer: 14dp

**M Size:**
- Leading icon block: 24dp
- Left outer: 24dp
- Gap: 8dp
- Label right: 24dp
- Trailing left inner: 13dp
- Right outer: 17dp

**L Size:**
- Leading icon block: 32dp
- Left outer: 48dp
- Gap: 12dp
- Label right: 48dp
- Trailing left inner: 26dp
- Right outer: 32dp

**XL Size:**
- Leading icon block: 40dp
- Left outer: 64dp
- Gap: 16dp
- Label right: 64dp
- Trailing left inner: 37dp
- Right outer: 49dp

### Symmetrical Paddings (Selected State)

When trailing segment is selected (menu open):

| Size | Side Padding | Total Width |
|------|--------------|-------------|
| XS | 13dp | 48dp (22 + 13 + 13) |
| S | 13dp | 48dp |
| M | 15dp | 56dp (26 + 15 + 15) |
| L | 29dp | 96dp (38 + 29 + 29) |
| XL | 43dp | 136dp (50 + 43 + 43) |

*Note: XS/SM selected total width is fixed at 48dp with 13dp side padding; no full rounding morph*

---

## Flutter Implementation

### Widget Overview

`SplitButtonM3E<T>` is a two-part button with a primary action and a dropdown menu.

### Constructor

```dart
SplitButtonM3E<String>(
  size: SplitButtonM3ESize.md,
  shape: SplitButtonM3EShape.round,
  emphasis: SplitButtonM3EEmphasis.tonal,
  label: 'Save',
  leadingIcon: Icons.save_outlined,
  onPressed: () => debugPrint('Primary pressed'),
  items: const [
    SplitButtonM3EItem<String>(value: 'draft', child: 'Save as draft'),
    SplitButtonM3EItem<String>(value: 'close', child: 'Save & close'),
  ],
  onSelected: (v) => debugPrint('Selected: $v'),
  leadingTooltip: 'Save',
  trailingTooltip: 'Open menu',
)
```

### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `size` | `SplitButtonM3ESize` | xs, sm, md, lg, xl |
| `shape` | `SplitButtonM3EShape` | round, square |
| `emphasis` | `SplitButtonM3EEmphasis` | filled, tonal, elevated, outlined, text |
| `label` | `String?` | Leading segment label |
| `leadingIcon` | `IconData?` | Leading segment icon |
| `onPressed` | `VoidCallback?` | Primary action callback |
| `items` | `List<SplitButtonM3EItem<T>>` | Menu items |
| `menuBuilder` | `List<PopupMenuEntry<T>> Function(BuildContext)?` | Custom menu builder |
| `onSelected` | `ValueChanged<T>?` | Selection callback |
| `trailingAlignment` | `SplitButtonM3ETrailingAlignment` | opticalCenter, geometricCenter |
| `leadingTooltip` | `String?` | Leading segment tooltip |
| `trailingTooltip` | `String?` | Trailing segment tooltip |
| `enabled` | `bool` | Enable/disable state (default: true) |

### Menu Item Definition

```dart
const SplitButtonM3EItem<T>({
  required T value,
  required Object child, // String or Widget
  bool enabled = true,
});
```

---

## Visual Specifications

### Emphasis Variants

**Filled:** Primary filled background, high emphasis
**Tonal:** Secondary container background, medium emphasis  
**Elevated:** Elevated surface with shadow, medium emphasis
**Outlined:** Transparent with border, low emphasis
**Text:** No background or border, lowest emphasis

### Colors (Material 3)

**Filled Emphasis:**
- Background: `primary`
- Foreground: `onPrimary`

**Tonal Emphasis:**
- Background: `secondaryContainer`
- Foreground: `onSecondaryContainer`

**Elevated Emphasis:**
- Background: `surfaceContainerLow`
- Foreground: `primary`
- Shadow: Elevation level 1

**Outlined Emphasis:**
- Background: Transparent
- Foreground: `primary`
- Border: `outline`

**Text Emphasis:**
- Background: Transparent
- Foreground: `primary`

### Shape Morphing Behavior

**Round Shape (M/L/XL sizes):**
- Unselected: Asymmetrical layout with optical offset
- Pressed/Selected: Trailing segment morphs into perfect circle
- Circle diameter = control height
- No inner padding when morphed
- No optical offset when morphed

**Round Shape (XS/S sizes):**
- Unselected: Asymmetrical layout
- Selected: Remains rectangular with symmetrical padding
- Total width fixed at 48dp
- No circle morph

**Square Shape:**
- All sizes maintain rectangular shape
- Inner corners use specified radius (4dp, 8dp, or 12dp)
- Outer corners: Fully rounded (pill shape)

---

## Behavior & Interactions

### Interaction States

**Resting (Unselected):**
- Asymmetrical padding layout
- Optical chevron offset applied
- Chevron points down (0° rotation)

**Hover:**
- Background color shifts to hover state
- Elevation increases (for elevated variant)

**Pressed:**
- Leading: Standard pressed state
- Trailing: Morphs to circle (M/L/XL round shape)
- Background color shifts to pressed state

**Selected (Menu Open):**
- Trailing segment in selected state
- Chevron rotates 180° (points up)
- Menu opens aligned to trailing edge
- Symmetrical padding applied

### Menu Behavior

- Opens aligned to trailing edge of arrow button
- Right edge in LTR layouts
- Left edge in RTL layouts
- Chevron rotates 180° when open
- Dismisses on outside tap or item selection

### Animation Specifications

**Chevron Rotation:**
- Duration: 200ms
- Curve: `easeInOut`
- Rotation: 0° → 180°

**Shape Morph (M/L/XL Round):**
- Duration: 150ms
- Curve: `easeInOutCubicEmphasized`
- Morphs from rounded rectangle to circle

**Menu Open:**
- Duration: 250ms
- Fade + scale from anchor point

---

## Usage Guidelines

### When to Use

✅ **Appropriate Use:**
- Primary action with related secondary options
- Save actions (Save, Save as draft, Save & close)
- Share actions (Share, Copy link, Email)
- Export actions (Export, Export as PDF, Export as PNG)
- Actions with recent/favorite options

❌ **Avoid Using:**
- Unrelated actions in the menu
- When menu has more than 5-6 items (use full dropdown)
- Single action without alternatives (use regular button)

### Best Practices

1. **Menu Items**: Keep related to primary action
2. **Label Clarity**: Use action verbs for primary label
3. **Icon Consistency**: Use recognizable icons
4. **Tooltip**: Always provide tooltips for accessibility
5. **Size Appropriateness**: Use larger sizes (L/XL) for touch-first interfaces

---

## Accessibility

### Requirements

- Each segment independently focusable
- Minimum 48×48dp touch target per segment
- Tooltips provide accessible names
- Chevron rotation conveys menu state
- Keyboard navigation support
- Screen reader friendly

### Implementation

```dart
SplitButtonM3E<String>(
  label: 'Save',
  leadingIcon: Icons.save,
  leadingTooltip: 'Save document',  // Accessibility
  trailingTooltip: 'More save options',  // Accessibility
  // ... other properties
)
```

### Testing Checklist

- [ ] Each segment has 48×48dp minimum touch target
- [ ] Leading tooltip describes primary action
- [ ] Trailing tooltip describes menu action
- [ ] Menu can be opened/closed via keyboard
- [ ] Menu items can be navigated via keyboard
- [ ] Selected state announced by screen reader

---

## Code Examples

### Basic Usage

```dart
SplitButtonM3E<String>(
  label: 'Save',
  leadingIcon: Icons.save_outlined,
  onPressed: () => saveDocument(),
  items: const [
    SplitButtonM3EItem(value: 'draft', child: 'Save as draft'),
    SplitButtonM3EItem(value: 'close', child: 'Save & close'),
  ],
  onSelected: (value) => handleSaveOption(value),
)
```

### Custom Menu Builder

```dart
SplitButtonM3E<int>(
  size: SplitButtonM3ESize.md,
  shape: SplitButtonM3EShape.square,
  label: 'More',
  leadingIcon: Icons.more_horiz,
  onPressed: () => showPrimaryAction(),
  menuBuilder: (context) => [
    const PopupMenuItem<int>(value: 1, child: Text('Option 1')),
    const PopupMenuItem<int>(value: 2, child: Text('Option 2')),
  ],
  onSelected: (value) => handleSelection(value),
  trailingAlignment: SplitButtonM3ETrailingAlignment.opticalCenter,
)
```

### Size Variants

```dart
Column(
  children: [
    SplitButtonM3E(size: SplitButtonM3ESize.xs, label: 'XS'),
    SplitButtonM3E(size: SplitButtonM3ESize.sm, label: 'Small'),
    SplitButtonM3E(size: SplitButtonM3ESize.md, label: 'Medium'),
    SplitButtonM3E(size: SplitButtonM3ESize.lg, label: 'Large'),
    SplitButtonM3E(size: SplitButtonM3ESize.xl, label: 'XL'),
  ],
)
```

### Emphasis Variants

```dart
Row(
  children: [
    SplitButtonM3E(
      emphasis: SplitButtonM3EEmphasis.filled,
      label: 'Filled',
    ),
    SplitButtonM3E(
      emphasis: SplitButtonM3EEmphasis.tonal,
      label: 'Tonal',
    ),
    SplitButtonM3E(
      emphasis: SplitButtonM3EEmphasis.elevated,
      label: 'Elevated',
    ),
    SplitButtonM3E(
      emphasis: SplitButtonM3EEmphasis.outlined,
      label: 'Outlined',
    ),
    SplitButtonM3E(
      emphasis: SplitButtonM3EEmphasis.text,
      label: 'Text',
    ),
  ],
)
```

---

## Related Components

| Component | Use Case | Difference |
|-----------|----------|------------|
| `ButtonGroup` | Multiple related buttons | No primary/secondary split |
| `DropdownButton` | Single selection from menu | No primary action |
| `MenuBar` | Top-level navigation | Multiple menus, not split |
| `PopupMenuButton` | Contextual menu | Icon-only trigger |

---

## References

- [Material 3 Split Button Specs](https://m3.material.io/components/split-button/specs)
- [Material 3 Split Button Overview](https://m3.material.io/components/split-button/overview)
- [SplitButtonM3E Package](https://pub.dev/packages/split_button_m3e)
- [SplitButtonLayout Compose Docs](https://composables.com/docs/androidx.compose.material3/material3/components/SplitButtonLayout)
- [Material 3 Expressive Article](https://proandroiddev.com/material-3-expressive-design-a-new-era-9ea77959a262)

---

## Image References

**Pub Package Cover:**
https://pub.dev/static/hash-4ut0obnn/img/pub-dev-icon-cover-image.png

**Material 3 Design System:**
https://m3.material.io/components/split-button/overview

**GitHub Repository:**
https://github.com/EmilyMoonstone/material_3_expressive/tree/main/packages/split_button_m3e

**API Documentation:**
https://pub.dev/documentation/split_button_m3e/latest/
