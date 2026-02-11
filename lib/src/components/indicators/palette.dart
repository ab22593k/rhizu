import 'package:flutter/material.dart';

@immutable
class Palette {
  const Palette(this.cs);
  final ColorScheme cs;

  // Use theme roles; callers can override colors if needed.
  Color get active => cs.primary;
  Color get track => cs.onSurfaceVariant.withValues(alpha: 0.24);
  Color get bg => cs.surface;
}
