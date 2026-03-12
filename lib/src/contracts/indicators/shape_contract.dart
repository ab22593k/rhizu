/// Defines the contract for shape types used in loading indicators.
///
/// Each shape type corresponds to a unique polar shape that can be morphed
/// into other shapes during the loading animation sequence.
abstract class ShapeContract {
  /// Unique identifier for this shape type.
  String get id;

  /// SVG path data used to generate the polar shape.
  String get svgPath;

  /// Human-readable name of the shape.
  String get displayName;
}

/// Defines the types of shapes used in the loading indicator animation.
enum ShapeType implements ShapeContract {
  /// A soft star-burst shape with gentle undulations.
  softBurst(
    id: 'soft_burst',
    svgPath: '',
    displayName: 'Soft Burst',
  ),

  /// A cookie-like shape with 9 scalloped edges.
  cookie9(
    id: 'cookie_9',
    svgPath: '',
    displayName: 'Cookie 9',
  ),

  /// A regular pentagon shape.
  pentagon(
    id: 'pentagon',
    svgPath: '',
    displayName: 'Pentagon',
  ),

  /// A pill/capsule shape (rounded rectangle rotated 45 degrees).
  pill(
    id: 'pill',
    svgPath: '',
    displayName: 'Pill',
  ),

  /// A sun-like shape with rounded corners.
  sunny(
    id: 'sunny',
    svgPath: '',
    displayName: 'Sunny',
  ),

  /// A cookie-like shape with 4 scalloped edges.
  cookie4(
    id: 'cookie_4',
    svgPath: '',
    displayName: 'Cookie 4',
  ),

  /// An oval/ellipse shape rotated 45 degrees.
  oval(
    id: 'oval',
    svgPath: '',
    displayName: 'Oval',
  )
  ;

  const ShapeType({
    required this.id,
    required this.svgPath,
    required this.displayName,
  });

  @override
  final String id;

  @override
  final String svgPath;

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
