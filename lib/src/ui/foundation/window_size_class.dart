enum WindowSizeClass {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  static WindowSizeClass fromWidth(double width) => switch (width) {
    < 600 => WindowSizeClass.compact,
    < 840 => WindowSizeClass.medium,
    < 1200 => WindowSizeClass.expanded,
    < 1600 => WindowSizeClass.large,
    _ => WindowSizeClass.extraLarge,
  };
}
