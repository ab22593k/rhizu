/// Defines the types of shapes used in the loading indicator animation.
///
/// Each shape type corresponds to a unique polar shape that can be morphed
/// into other shapes during the loading animation sequence.
enum ShapeType {
  /// A star-burst shape with multiple points radiating outward.
  burst,

  /// A cookie-like shape with 9 scalloped edges.
  cookie9,

  /// A regular pentagon shape.
  pentagon,

  /// A pill/capsule shape (rounded rectangle rotated 45 degrees).
  pill,

  /// A sun-like shape with rounded corners.
  sunny,

  /// A cookie-like shape with 4 scalloped edges.
  cookie4,

  /// An oval/ellipse shape rotated 45 degrees.
  oval,
}

/// The default sequence of shapes for the loading indicator animation.
///
/// This sequence defines the order in which shapes morph from one to another
/// during the continuous animation loop.
const List<ShapeType> defaultShapeSequence = [
  ShapeType.burst,
  ShapeType.cookie9,
  ShapeType.pentagon,
  ShapeType.pill,
  ShapeType.sunny,
  ShapeType.cookie4,
  ShapeType.oval,
];
