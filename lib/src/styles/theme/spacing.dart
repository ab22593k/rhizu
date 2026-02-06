import 'package:rhizu/src/foundations/window_size_class.dart';

class ExpressiveSpacing {
  static double margin(WindowSizeClass sizeClass) {
    switch (sizeClass) {
      case WindowSizeClass.compact:
        return 16;
      case WindowSizeClass.medium:
        return 24;
      case WindowSizeClass.expanded:
      case WindowSizeClass.large:
      case WindowSizeClass.extraLarge:
        return 32;
    }
  }
}
