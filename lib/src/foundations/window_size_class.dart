enum WindowSizeClass {
  compact,
  medium,
  expanded,
  large,
  extraLarge;

  static WindowSizeClass fromWidth(double width) {
    if (width < 600) return WindowSizeClass.compact;
    if (width < 840) return WindowSizeClass.medium;
    if (width < 1200) return WindowSizeClass.expanded;
    if (width < 1600) return WindowSizeClass.large;
    return WindowSizeClass.extraLarge;
  }
}
