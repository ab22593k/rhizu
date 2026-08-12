# Rhizu

Single Flutter package; there is no runnable app, workspace task runner, codegen,
or repository CI configuration.

## Toolchain and commands

- Use a Flutter SDK with Dart `>=3.12.*`; source files use Flutter's
  built-in `package:flutter/widget_previews.dart` API.
- Install dependencies: `flutter pub get`.
- Before handoff, run:
  1. `dart format --output=none --set-exit-if-changed lib test`
  2. `flutter analyze`
  3. `flutter test`
- Focus one file with `flutter test test/path/to/file_test.dart`; focus one case
  with `flutter test test/path/to/file_test.dart --plain-name 'test name'`.
- Launch the source-annotated `@Preview` widgets with
  `flutter widget-preview start`.
- `pubspec.lock` is intentionally ignored because this is a package; do not add
  it to version control.

## Package boundaries

- `lib/rhizu.dart` is the consumer-facing API barrel; add new public API there.
  It also re-exports `flutter_animate`, `go_router`, `google_fonts`, and
  `hugeicons`, so removing those exports changes the package API.
- Active implementation is under `lib/src/ui`; indicator internals additionally
  use `contracts/`, `providers/`, and `core/registry/`. The `.gitkeep`-only data,
  domain, view-model, and view directories are scaffolding, not active layers.
- `assets/shapes/` is a package asset directory declared in `pubspec.yaml`.
  Keep `RZShapes` paths in `lib/src/ui/styles/shapes/static.dart` synchronized
  when adding or renaming SVGs.

## Checks that differ from Flutter defaults

- Analysis extends `very_good_analysis`, with the explicit exceptions in
  `analysis_options.yaml`; run `flutter analyze`, not only the default lints.
- Widget behavior is checked with `flutter_test`; there are currently no golden
  tests or integration-test prerequisites.
