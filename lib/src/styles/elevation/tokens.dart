/// Material 3 Elevation System Tokens.
///
/// These tokens follow the Design System Package (DSP) naming convention
/// and provide elevation levels (z-axis distance) in density-independent pixels (dp).
class ElevationTokens {
  const ElevationTokens._();

  /// Elevation Level 0 (0.0dp)
  ///
  /// Usage: Resting state for filled/outlined buttons, standard cards, tabs.
  static const double level0 = 0.0;

  /// Elevation Level 1 (1.0dp)
  ///
  /// Usage: Resting state for elevated buttons, elevated cards, elevated chips.
  static const double level1 = 1.0;

  /// Elevation Level 2 (3.0dp)
  ///
  /// Usage: Scrolled state for app bars, menus, navigation bars.
  static const double level2 = 3.0;

  /// Elevation Level 3 (6.0dp)
  ///
  /// Usage: Resting state for FABs, dialogs, search bars, pickers.
  static const double level3 = 6.0;

  /// Elevation Level 4 (8.0dp)
  ///
  /// Usage: Hover/Focus state for Level 3 components.
  static const double level4 = 8.0;

  /// Elevation Level 5 (12.0dp)
  ///
  /// Usage: Dragged state for components.
  static const double level5 = 12.0;

  /// Scrim Opacity (32%)
  ///
  /// Usage: Opacity for the scrim color used in modal barriers.
  static const double scrimOpacity = 0.32;
}
