import 'package:rhizu/src/ui/components/indicators/shapes/polar_shape.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_asset_store.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_type.dart';

/// Provider implementation for shapes.
///
/// This satisfies the contract defined in /contracts by providing
/// concrete implementations of shape rendering logic. Shape geometry is
/// loaded from the `assets/shapes/` SVGs via [ShapeAssetStore].
class ShapeProvider {
  ShapeProvider._({
    required this.shapeType,
    required this.assetPath,
  });

  /// Creates a default provider for the given shape type.
  factory ShapeProvider.defaultFor(ShapeType type) {
    return ShapeProvider._(
      shapeType: type,
      assetPath: type.assetPath,
    );
  }

  final ShapeType shapeType;

  /// The `RZShapes` asset path of the SVG defining this shape.
  final String assetPath;

  /// Gets the polar shape for this provider.
  ///
  /// Requires the shape assets to have been prewarmed.
  PolarShape get polarShape => ShapeAssetStore.shapeFor(assetPath);

  /// Loads this provider's shape asset into the store.
  Future<void> prewarm() => ShapeAssetStore.prewarm([assetPath]);
}
