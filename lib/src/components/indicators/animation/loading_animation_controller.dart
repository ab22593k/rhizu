import 'package:flutter/material.dart';

import '../constants.dart';
import '../shapes/shape_type.dart';

/// Controller for the loading indicator animation.
///
/// This class manages both the rotation and morphing animations,
/// coordinating them to create the continuous loading effect.
/// The controller handles:
/// - Global rotation (360 degrees every 4666ms)
/// - Morphing between shapes (650ms per transition)
/// - Shape sequence progression (7 shapes in cycle)
class LoadingAnimationController {
  late final AnimationController _rotationController;
  late final AnimationController _morphController;

  int _currentIndex = 0;
  bool _isDisposed = false;

  final VoidCallback? _onShapeChange;
  final List<ShapeType> _shapeSequence;

  /// The current shape in the animation sequence.
  ShapeType get currentShape => _shapeSequence[_currentIndex];

  /// The next shape to morph to.
  ShapeType get nextShape =>
      _shapeSequence[(_currentIndex + 1) % _shapeSequence.length];

  /// The current index in the shape sequence.
  int get currentIndex => _currentIndex;

  /// Whether this controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// Creates a new animation controller.
  ///
  /// [vsync] provides the ticker for the animation controllers.
  /// [shapeSequence] defines the order of shape morphing (defaults to [defaultShapeSequence]).
  /// [onShapeChange] is called when the shape sequence advances to the next shape.
  LoadingAnimationController({
    required TickerProvider vsync,
    List<ShapeType>? shapeSequence,
    VoidCallback? onShapeChange,
  }) : _shapeSequence = shapeSequence ?? defaultShapeSequence,
       _onShapeChange = onShapeChange {
    // Global Rotation: 360 degrees every rotationDuration (Linear)
    _rotationController = AnimationController(
      vsync: vsync,
      duration: LoadingIndicatorConstants.rotationDuration,
    )..repeat();

    // Morph Animation: morphDuration per shape transition
    _morphController = AnimationController(
      vsync: vsync,
      duration: LoadingIndicatorConstants.morphDuration,
    );

    _startMorphSequence();
  }

  /// The rotation animation controller value [0, 1].
  double get rotationValue => _rotationController.value;

  /// The morph animation controller value [0, 1].
  double get morphValue => _morphController.value;

  /// Returns a listenable that merges both animation controllers.
  ///
  /// Useful for listening to animation updates in widgets.
  Listenable get animation =>
      Listenable.merge([_morphController, _rotationController]);

  void _startMorphSequence() {
    _morphController.forward(from: 0.0).then((_) {
      if (!_isDisposed) {
        _currentIndex = (_currentIndex + 1) % _shapeSequence.length;
        _onShapeChange?.call();
        _startMorphSequence();
      }
    });
  }

  /// Disposes of the animation controllers.
  ///
  /// Must be called when the controller is no longer needed to prevent memory leaks.
  void dispose() {
    _isDisposed = true;
    _morphController.dispose();
    _rotationController.dispose();
  }
}
