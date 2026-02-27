# Material 3 Expressive FAB Menu - UI/UX Specifications

> Source: https://m3.material.io/components/fab-menu/overview
> Last Updated: 2026-02-15

## Overview

The **FAB Menu** (Floating Action Button Menu) is Material 3 Expressive's solution for overflow actions tied to a Floating Action Button. It transforms a single FAB into an expandable menu, revealing a set of related secondary actions while keeping the primary action prominent.

## Key Features

- **Expandable Menu:** Opens from a FAB to display multiple related actions
- **Staggered Animations:** Smooth, staggered animation of menu items when expanding/collapsing
- **Toggle State:** FAB acts as a toggle button showing expanded/collapsed states
- **Contextual Relevance:** Groups related actions under a primary FAB action
- **Thumb-Friendly:** Optimized for mobile interaction patterns
- **Minimalist Interface:** Keeps secondary actions hidden until needed

---

## Component Anatomy

### 1. Toggle Floating Action Button (FAB)

The main FAB that triggers the menu expansion:

**Characteristics:**
- Acts as a toggle with expanded/collapsed states
- Shows state change via icon rotation or transformation
- Can be small, standard, or large size
- Typically positioned at bottom-right or bottom-center

**States:**
- **Collapsed:** Default state, shows primary icon
- **Expanded:** Menu is open, icon may rotate (e.g., + to ×)

### 2. FAB Menu Container

The container that holds the menu items:

**Characteristics:**
- Expands from the FAB position
- Can be vertical or horizontal orientation
- Contains 2-5 related action items
- Animates with staggered entrance/exit

### 3. FAB Menu Items

Individual action items within the menu:

**Characteristics:**
- Small rounded corners (8dp-12dp depending on size)
- Icon + label combination
- Elevation shadow when expanded
- Staggered animation delay between items
- Can have different emphasis levels

---

## Layout Variants

### Vertical FAB Menu (Default)
- Items stack vertically above or below the FAB
- Most common pattern
- Best for 2-5 actions
- Natural thumb reach on mobile

### Horizontal FAB Menu
- Items arrange horizontally
- Useful for wider screens or bottom-center placement
- Can expand left or right from FAB

---

## Sizes

### Small FAB Menu
- **Item Height:** 32-40dp
- **Icon Size:** 18-20dp
- **Corner Radius:** 8dp
- **Spacing:** 8dp between items

### Standard FAB Menu (Default)
- **Item Height:** 48-56dp
- **Icon Size:** 24dp
- **Corner Radius:** 12dp
- **Spacing:** 12dp between items

### Large FAB Menu
- **Item Height:** 64-80dp
- **Icon Size:** 32dp
- **Corner Radius:** 16dp
- **Spacing:** 16dp between items

---

## Animation Specifications

### Expansion Animation
- **Duration:** 250-300ms
- **Easing:** `easeInOutCubicEmphasized`
- **Stagger Delay:** 30-50ms between items
- **Scale:** Items scale from 0 to 1
- **Opacity:** Fade from 0 to 1

### Collapse Animation
- **Duration:** 200-250ms
- **Easing:** `easeInOutCubicEmphasized`
- **Reverse Stagger:** Items collapse in reverse order

### FAB Icon Rotation
- **Duration:** 200ms
- **Rotation:** 0° to 45° (for + to × transformation)
- **Easing:** `easeInOut`

---

## Color Styles

### Primary Emphasis
- **Container:** `primaryContainer`
- **Content:** `onPrimaryContainer`
- Use for primary actions

### Secondary Emphasis
- **Container:** `secondaryContainer`
- **Content:** `onSecondaryContainer`
- Use for secondary actions

### Surface Emphasis
- **Container:** `surfaceContainerHigh`
- **Content:** `onSurface`
- Use for neutral actions

### Tonal Emphasis
- **Container:** Tonal variant of primary
- **Content:** Matching content color
- Use for subtle emphasis

---

## Behavior & Interactions

### Opening the Menu
1. User taps the FAB
2. FAB icon animates (rotation)
3. Menu container appears
4. Items animate in with stagger
5. Backdrop/dim may appear (optional)

### Closing the Menu
1. User taps FAB again, taps outside, or taps an item
2. Items animate out in reverse stagger
3. FAB icon reverses animation
4. Menu container disappears

### Selecting an Item
1. User taps menu item
2. Menu closes
3. Selected action executes
4. Optional haptic feedback

### Back Handler Support
- Android back button closes menu
- No navigation occurs

---

## Usage Guidelines

### Do's
- Use for 2-5 related actions
- Group logically related actions
- Use consistent iconography
- Provide clear labels for accessibility
- Keep animations smooth and performant
- Use haptic feedback on item selection

### Don'ts
- Don't use for more than 5 actions (consider bottom sheet)
- Don't mix unrelated actions
- Don't block critical content when expanded
- Don't use without proper accessibility labels
- Don't place where it conflicts with system gestures

---

## Implementation Resources

### Flutter
- **FloatingActionButton:** Available
- **FloatingActionButtonMenu:** Material 3 Expressive
- Status: Available in `flutter/material.dart`

### Android (Jetpack Compose)
- **FloatingActionButtonMenu:** Available
- **ToggleFloatingActionButton:** Available
- **FloatingActionButtonMenuItem:** Available
- Status: Available in Material 3 Expressive

### iOS
- Not available natively
- Custom implementation required

### Web
- Not available
- Custom implementation required

### Design Kit
- **Figma:** https://www.figma.com/community/file/1035203688168086460

---

## Accessibility

### Screen Readers
- FAB announces as "Menu button, collapsed/expanded"
- Each menu item announces label and state
- Menu container announces number of items

### Focus Management
- Focus moves to first menu item when expanded
- Tab/arrow navigation between items
- Focus returns to FAB when collapsed

### Touch Targets
- Minimum 48dp touch target for each item
- Adequate spacing between items (8dp minimum)

---

## Design Images

### FAB Menu Overview
![FAB Menu expanded showing multiple action items](https://m3.material.io/components/fab-menu/overview)

### FAB Menu States
![FAB Menu showing collapsed and expanded states](https://m3.material.io/components/fab-menu/specs)

### FAB Menu Anatomy
![FAB Menu component anatomy breakdown](https://m3.material.io/components/fab-menu/guidelines)

---

## Related Components

- **Floating Action Button (FAB)** - The base component
- **Extended FAB** - FAB with text label
- **Toolbars** - Alternative for persistent actions
- **Bottom Sheets** - Alternative for many actions
- **Menus** - Standard menu component

---

## References

- Material 3 FAB Menu Overview: https://m3.material.io/components/fab-menu/overview
- Material 3 FAB Menu Specs: https://m3.material.io/components/fab-menu/specs
- Material 3 FAB Menu Guidelines: https://m3.material.io/components/fab-menu/guidelines
- Android Compose API: https://developer.android.com/reference/kotlin/androidx/compose/material3/FloatingActionButtonMenu
- M3 Expressive Blog: https://m3.material.io/blog/building-with-m3-expressive
