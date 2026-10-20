# Rhizu ✨ — Material 3 Expressive components for Flutter

[![Flutter](https://img.shields.io/badge/Flutter-Material%203-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2?style=flat-square&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/github/license/ab22593k/rhizu?style=flat-square)](LICENSE)

Rhizu is a Flutter package of Material 3 Expressive widgets, adaptive layouts,
and design tokens. It is for apps that want the expressive component language
without reimplementing it in every project.

## Install

Requires Dart 3.12 or newer. Add the package from Git:

```yaml
dependencies:
  rhizu:
    git:
      url: https://github.com/ab22593k/rhizu.git
      ref: main
```

For a local checkout, use a path dependency instead:

```yaml
dependencies:
  rhizu:
    path: ../rhizu
```

Then run:

```sh
flutter pub get
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:rhizu/rhizu.dart';

void main() => runApp(
  MaterialApp(
    home: Scaffold(
      body: Center(
        child: ButtonGroup<int>(
          selected: const {1},
          items: const [
            ButtonGroupItem(value: 1, label: 'Day'),
            ButtonGroupItem(value: 2, label: 'Week'),
            ButtonGroupItem(value: 3, label: 'Month'),
          ],
        ),
      ),
    ),
  ),
);
```

Pass `onSelectionChanged` to make the group interactive. Importing
`package:rhizu/rhizu.dart` also re-exports `flutter_animate`, `go_router`,
`google_fonts`, and `hugeicons`.

## Components

- **Buttons** — `ButtonGroup` for standard and connected groups with selection
  and overflow, and `SplitButton` for split primary actions and menus.
- **Indicators** — `MorphingLoadingindicator`, `ProgressIndicator`, and
  `PullToRefresh`.
- **Toolbars and menus** — `RZToolbar` and `RZFabMenu`.
- **Scrolling** — `SmoothScrollPhysics` and `SmoothScrolling`.

## Layouts

`WindowSizeClass` classifies width as compact, medium, expanded, large, or
extra large. `FeedLayout`, `RZLandingLayout`, `RZListDetailLayout`,
`RZSupportingPaneLayout`, and `RZAdaptiveNavigationShell` adapt to that
classification.

```dart
int feedColumns(BuildContext context) {
  final sizeClass = WindowSizeClass.fromWidth(
    MediaQuery.sizeOf(context).width,
  );
  return FeedLayout.crossAxisCountFor(sizeClass);
}
```

## Theme and tokens

`RZTheme.fallback()` installs `RZElevation`, `RZShape`, and `RZMotion` as
theme extensions. `RZRadius`, `RZSpacing`, `MotionTokens`, `ShapeTokens`, and
`RZShapes` are available directly.

```dart
ThemeData rhizuTheme() => ThemeData(
  extensions: <ThemeExtension<dynamic>>[RZTheme.fallback()],
);
```

## Previews

The package includes `@Preview` widgets for its components and layouts. Start
the preview environment with:

```sh
flutter widget-preview start
```

This requires a Flutter SDK that includes `flutter widget-preview`.

## Development

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## License

MIT — see [LICENSE](LICENSE).
