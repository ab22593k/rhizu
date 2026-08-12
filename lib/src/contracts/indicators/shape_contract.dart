/// Defines the contract for shape types used in loading indicators.
///
/// Every shape is defined by an SVG in `assets/shapes/` (see `RZShapes` for
/// the canonical asset paths). The [ShapeType] enum enumerates the selectable
/// shapes; the geometry itself lives in the assets and is loaded through the
/// shape asset store.
abstract class ShapeContract {
  /// Unique identifier for this shape type.
  String get id;

  /// Human-readable name of the shape.
  String get displayName;
}

/// Defines the types of shapes used in the loading indicator animation.
///
/// Each shape type corresponds to a unique polar shape that can be morphed
/// into other shapes during the loading animation sequence.
enum ShapeType implements ShapeContract {
  /// A soft star-burst shape with gentle undulations.
  softBurst(
    id: 'soft_burst',
    displayName: 'Soft Burst',
  ),

  /// A cookie-like shape with 9 scalloped edges.
  cookie9(
    id: 'cookie_9',
    displayName: 'Cookie 9',
  ),

  /// A regular pentagon shape.
  pentagon(
    id: 'pentagon',
    displayName: 'Pentagon',
  ),

  /// A pill/capsule shape (rounded rectangle rotated 45 degrees).
  pill(
    id: 'pill',
    displayName: 'Pill',
  ),

  /// A sun-like shape with rounded corners.
  sunny(
    id: 'sunny',
    displayName: 'Sunny',
  ),

  /// A cookie-like shape with 4 scalloped edges.
  cookie4(
    id: 'cookie_4',
    displayName: 'Cookie 4',
  ),

  /// An oval/ellipse shape rotated 45 degrees.
  oval(
    id: 'oval',
    displayName: 'Oval',
  ),

  /// An arch shape.
  arch(
    id: 'arch',
    displayName: 'Arch',
  ),

  /// An arrow shape.
  arrow(
    id: 'arrow',
    displayName: 'Arrow',
  ),

  /// An exploding boom shape.
  boom(
    id: 'boom',
    displayName: 'Boom',
  ),

  /// A bun shape.
  bun(
    id: 'bun',
    displayName: 'Bun',
  ),

  /// A burst shape.
  burst(
    id: 'burst',
    displayName: 'Burst',
  ),

  /// A circle shape.
  circle(
    id: 'circle',
    displayName: 'Circle',
  ),

  /// A clover shape with 4 leaves.
  clover4(
    id: 'clover_4',
    displayName: 'Clover 4',
  ),

  /// A clover shape with 8 leaves.
  clover8(
    id: 'clover_8',
    displayName: 'Clover 8',
  ),

  /// A cookie-like shape with 12 scalloped edges.
  cookie12(
    id: 'cookie_12',
    displayName: 'Cookie 12',
  ),

  /// A cookie-like shape with 6 scalloped edges.
  cookie6(
    id: 'cookie_6',
    displayName: 'Cookie 6',
  ),

  /// A cookie-like shape with 7 scalloped edges.
  cookie7(
    id: 'cookie_7',
    displayName: 'Cookie 7',
  ),

  /// A diamond shape.
  diamond(
    id: 'diamond',
    displayName: 'Diamond',
  ),

  /// A fan shape.
  fan(
    id: 'fan',
    displayName: 'Fan',
  ),

  /// A flower shape.
  flower(
    id: 'flower',
    displayName: 'Flower',
  ),

  /// A gem shape.
  gem(
    id: 'gem',
    displayName: 'Gem',
  ),

  /// A ghostish shape.
  ghostish(
    id: 'ghostish',
    displayName: 'Ghostish',
  ),

  /// A heart shape.
  heart(
    id: 'heart',
    displayName: 'Heart',
  ),

  /// A hexagon shape.
  hexagon(
    id: 'hexagon',
    displayName: 'Hexagon',
  ),

  /// A pixelated circle shape.
  pixelCircle(
    id: 'pixel_circle',
    displayName: 'Pixel Circle',
  ),

  /// A pixelated triangle shape.
  pixelTriangle(
    id: 'pixel_triangle',
    displayName: 'Pixel Triangle',
  ),

  /// A puffy cloud-like shape.
  puffy(
    id: 'puffy',
    displayName: 'Puffy',
  ),

  /// A puffy diamond shape.
  puffyDiamond(
    id: 'puffy_diamond',
    displayName: 'Puffy Diamond',
  ),

  /// A semicircle shape.
  semicircle(
    id: 'semicircle',
    displayName: 'Semicircle',
  ),

  /// A slanted square shape.
  slantedSquare(
    id: 'slanted_square',
    displayName: 'Slanted Square',
  ),

  /// A soft boom shape.
  softBoom(
    id: 'soft_boom',
    displayName: 'Soft Boom',
  ),

  /// A square shape.
  square(
    id: 'square',
    displayName: 'Square',
  ),

  /// A triangle shape.
  triangle(
    id: 'triangle',
    displayName: 'Triangle',
  ),

  /// A very sunny shape.
  verySunny(
    id: 'very_sunny',
    displayName: 'Very Sunny',
  );

  const ShapeType({
    required this.id,
    required this.displayName,
  });

  @override
  final String id;

  @override
  final String displayName;
}

/// The default sequence of shapes for the loading indicator animation.
const List<ShapeType> defaultShapeSequence = [
  ShapeType.softBurst,
  ShapeType.cookie9,
  ShapeType.pentagon,
  ShapeType.pill,
  ShapeType.sunny,
  ShapeType.cookie4,
  ShapeType.oval,
];
