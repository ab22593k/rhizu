import 'package:rhizu/src/ui/components/indicators/shapes/polar_shape.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_asset_store.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_type.dart';

/// A registry of all available shapes for the loading indicator.
///
/// Shapes are defined by the SVGs in `assets/shapes/` and loaded through
/// [ShapeAssetStore]. The registry exposes a synchronous lookup for the
/// morphing painter; the assets must be loaded first with [prewarm].
///
/// To avoid first-frame jank, call [prewarm] during app initialization
/// before the loading indicator is first displayed. The loading indicator
/// also prewarms on its first build.
class ShapeRegistry {
  const ShapeRegistry._();

  /// Gets the polar shape definition for the given shape type.
  ///
  /// Returns the cached, asset-backed shape. Throws a [StateError] if the
  /// shape assets have not been loaded yet (see [prewarm]).
  static PolarShape get(ShapeType type) {
    return ShapeAssetStore.shapeFor(type.assetPath);
  }

  /// Loads all shape assets into memory.
  ///
  /// Call this during app initialization, before `runApp`:
  /// ```dart
  /// void main() async {
  ///   await ShapeRegistry.prewarm();
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// Safe to call multiple times; already-loaded assets are skipped.
  static Future<void> prewarm() {
    return ShapeAssetStore.prewarm(
      ShapeType.values.map((type) => type.assetPath),
    );
  }

  /// Whether every shape type has been loaded from its asset.
  static bool get isReady {
    return ShapeType.values.every(
      (type) => ShapeAssetStore.isReadyFor(type.assetPath),
    );
  }
}
