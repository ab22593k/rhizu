import 'package:flutter/services.dart';

import 'package:rhizu/src/ui/components/indicators/shapes/polar_shape.dart';

/// Loads and caches polar shapes from the SVG assets in `assets/shapes/`.
///
/// Shape geometry lives in the package assets declared under `assets/shapes/`
/// (see `RZShapes` for the canonical asset paths). Because loading an asset is
/// asynchronous, the store loads every requested shape once during [prewarm]
/// and serves it synchronously afterwards through [shapeFor].
///
/// Accessing a shape before it has been prewarmed throws a [StateError].
class ShapeAssetStore {
  const ShapeAssetStore._();

  /// Cache of asset path -> parsed polar shape.
  static final Map<String, PolarShape> _shapes = {};

  /// Loads and caches the shapes for the given [assetPaths].
  ///
  /// Safe to call multiple times; already-loaded paths are skipped.
  ///
  /// Note for widget tests: asset loading is real async I/O, so it does not
  /// complete inside the FakeAsync zone used by `testWidgets`. Prewarm from
  /// an async `main()` before pumping widgets that assert on shapes.
  static Future<void> prewarm(Iterable<String> assetPaths) async {
    final missing = assetPaths.where((p) => !_shapes.containsKey(p)).toSet();
    if (missing.isEmpty) return;

    final loaded = await Future.wait(missing.map(_load));
    for (final (path, shape) in loaded) {
      _shapes[path] = shape;
    }
  }

  static Future<(String, PolarShape)> _load(String assetPath) async {
    final svg = await rootBundle.loadString(assetPath);
    return (assetPath, PolarShape.fromSvgPath(extractSvgPathData(svg)));
  }

  /// Whether the shape for [assetPath] has been loaded.
  static bool isReadyFor(String assetPath) => _shapes.containsKey(assetPath);

  /// Returns the cached polar shape for [assetPath].
  ///
  /// Throws a [StateError] if the asset has not been loaded yet.
  static PolarShape shapeFor(String assetPath) {
    final shape = _shapes[assetPath];
    if (shape == null) {
      throw StateError(
        'Shape for asset "$assetPath" is not loaded. Call '
        '`await ShapeRegistry.prewarm()` before accessing shapes.',
      );
    }
    return shape;
  }

  /// Extracts the `d` attribute (path data) from an SVG document.
  ///
  /// The shape assets in `assets/shapes/` each contain a single `<path>`
  /// element whose `d` attribute holds the geometry consumed by
  /// [PolarShape.fromSvgPath].
  static String extractSvgPathData(String svg) {
    final match = RegExp(r'\bd\s*=\s*"([^"]*)"').firstMatch(svg);
    if (match == null) {
      throw const FormatException('No `d` attribute found in SVG document.');
    }
    return match.group(1)!;
  }
}
