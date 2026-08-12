import 'package:flutter/material.dart';

/// Color roles for progress indicators, following the merged M3 token set
/// (`md.comp.progress-indicator`):
///
/// - active-indicator.color → `md.sys.color.primary`
/// - track.color → `md.sys.color.secondary-container`
/// - stop-indicator.color → `md.sys.color.primary`
@immutable
class ProgressIndicatorPalette {
  const ProgressIndicatorPalette(this.cs);
  final ColorScheme cs;

  // Use theme roles; callers can override colors if needed.
  Color get active => cs.primary;
  Color get track => cs.secondaryContainer;
  Color get bg => cs.surface;
}
