/// Defines how the loading indicator is visually contained.
///
/// This affects both the background styling and the color
/// scheme applied to the indicator.
enum Containment {
  /// Simple loading indicator without a container.
  ///
  /// Uses the theme's primary color for the indicator.
  /// No background container is shown.
  simple,

  /// Contained loading indicator with a circular container.
  ///
  /// Uses the theme's primaryContainer color for the background
  /// and onPrimaryContainer color for the indicator.
  contained,
}
