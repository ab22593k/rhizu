import 'package:flutter/foundation.dart';

import 'package:rhizu/src/contracts/indicators/indicators.dart';
import 'package:rhizu/src/providers/indicators/shape_provider.dart';

/// Central registry for loading indicator implementations.
///
/// This is the core of the monolithic architecture - it maintains
/// a list of available implementations that satisfy the contracts.
/// Providers register themselves with this registry during initialization.
class LoadingIndicatorRegistry {
  LoadingIndicatorRegistry._();

  static final LoadingIndicatorRegistry instance = LoadingIndicatorRegistry._();

  final Map<ShapeType, ShapeProvider> _shapeProviders = {};

  bool _initialized = false;

  /// Registers a shape provider for a specific shape type.
  void registerShapeProvider(ShapeType type, ShapeProvider provider) {
    _shapeProviders[type] = provider;
  }

  /// Gets the shape provider for a specific type.
  ShapeProvider? getShapeProvider(ShapeType type) {
    return _shapeProviders[type];
  }

  /// Gets all registered shape providers.
  Map<ShapeType, ShapeProvider> get shapeProviders =>
      Map.unmodifiable(_shapeProviders);

  /// Initializes the registry with default providers.
  ///
  /// This follows the Tiered Init pattern from monolithic-maintainer:
  /// - Platform detection happens first
  /// - Then core services register themselves
  /// - Finally providers register their implementations
  void initialize() {
    if (_initialized) return;

    _registerDefaultProviders();
    _initialized = true;
  }

  void _registerDefaultProviders() {
    for (final type in ShapeType.values) {
      if (!_shapeProviders.containsKey(type)) {
        _shapeProviders[type] = ShapeProvider.defaultFor(type);
      }
    }
  }

  /// Prewarms all shape providers to avoid first-frame jank.
  ///
  /// Call this during app initialization:
  /// ```dart
  /// void main() {
  ///   LoadingIndicatorRegistry.instance.prewarm();
  ///   runApp(MyApp());
  /// }
  /// ```
  void prewarm() {
    initialize();
    for (final provider in _shapeProviders.values) {
      provider.prewarm();
    }
  }

  /// Whether the registry has been initialized.
  bool get isInitialized => _initialized;

  /// Resets the registry (useful for testing).
  @visibleForTesting
  void reset() {
    _shapeProviders.clear();
    _initialized = false;
  }
}

/// Extension to provide easy access to the registry.
extension LoadingIndicatorRegistryX on LoadingIndicatorRegistry {
  /// Convenience getter for the singleton instance.
  static LoadingIndicatorRegistry get registry =>
      LoadingIndicatorRegistry.instance;
}
