import 'package:rhizu/src/contracts/indicators/shape_contract.dart';
import 'package:rhizu/src/ui/styles/shapes/static.dart';

export 'package:rhizu/src/contracts/indicators/shape_contract.dart'
    show ShapeType, defaultShapeSequence;

/// Canonical package asset path for each [ShapeType].
///
/// Every shape is defined by an SVG in `assets/shapes/`; this maps each
/// selectable shape to its `RZShapes` asset path.
extension ShapeTypeAssetPathX on ShapeType {
  /// The `RZShapes` asset path of the SVG that defines this shape.
  String get assetPath => switch (this) {
    ShapeType.softBurst => RZShapes.softBurst,
    ShapeType.cookie9 => RZShapes.cookie9,
    ShapeType.pentagon => RZShapes.pentagon,
    ShapeType.pill => RZShapes.pill,
    ShapeType.sunny => RZShapes.sunny,
    ShapeType.cookie4 => RZShapes.cookie4,
    ShapeType.oval => RZShapes.oval,
    ShapeType.arch => RZShapes.arch,
    ShapeType.arrow => RZShapes.arrow,
    ShapeType.boom => RZShapes.boom,
    ShapeType.bun => RZShapes.bun,
    ShapeType.burst => RZShapes.burst,
    ShapeType.circle => RZShapes.circle,
    ShapeType.clover4 => RZShapes.clover4,
    ShapeType.clover8 => RZShapes.clover8,
    ShapeType.cookie12 => RZShapes.cookie12,
    ShapeType.cookie6 => RZShapes.cookie6,
    ShapeType.cookie7 => RZShapes.cookie7,
    ShapeType.diamond => RZShapes.diamond,
    ShapeType.fan => RZShapes.fan,
    ShapeType.flower => RZShapes.flower,
    ShapeType.gem => RZShapes.gem,
    ShapeType.ghostish => RZShapes.ghostish,
    ShapeType.heart => RZShapes.heart,
    ShapeType.hexagon => RZShapes.hexagon,
    ShapeType.pixelCircle => RZShapes.pixelCircle,
    ShapeType.pixelTriangle => RZShapes.pixelTriangle,
    ShapeType.puffy => RZShapes.puffy,
    ShapeType.puffyDiamond => RZShapes.puffyDiamond,
    ShapeType.semicircle => RZShapes.semicircle,
    ShapeType.slantedSquare => RZShapes.slantedSquare,
    ShapeType.softBoom => RZShapes.softBoom,
    ShapeType.square => RZShapes.square,
    ShapeType.triangle => RZShapes.triangle,
    ShapeType.verySunny => RZShapes.verySunny,
  };
}
