import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_type.dart';

/// Controller for the loading indicator animation.
///
/// This class manages both the rotation and morphing animations,
/// coordinating them to create the continuous loading effect.
/// The controller handles:
/// - Global rotation (360 degrees every 4666ms)
/// - Morphing between shapes (650ms per transition)
/// - Shape sequence progression (7 shapes in the default cycle)
class LoadingAnimationController {
  /// Creates a new animation controller.
  ///
  /// [vsync] provides the ticker for the animation controllers.
  /// [shapeSequence] defines the order of shape morphing (defaults to
  /// [defaultShapeSequence]). An empty list also falls back to the default.
  /// [_onShapeChange] is called when the shape sequence advances to the next shape.
  LoadingAnimationController({
    required TickerProvider vsync,
    List<ShapeType>? shapeSequence,
    this._onShapeChange,
    bool animationsEnabled = true,
  }) : _shapeSequence = (shapeSequence == null || shapeSequence.isEmpty)
           ? defaultShapeSequence
           : List<ShapeType>.of(shapeSequence),
       _animationsEnabled = animationsEnabled {
    // Global Rotation: 360 degrees every rotationDuration (Linear)
    _rotationController = AnimationController(
      vsync: vsync,
      duration: LoadingIndicatorConstants.rotationDuration,
    );

    // Morph Animation: morphDuration per shape transition
    _morphController = AnimationController(
      vsync: vsync,
      duration: LoadingIndicatorConstants.morphDuration,
    );

    if (animationsEnabled) {
      _startAnimations();
    }
  }
  late final AnimationController _rotationController;
  late final AnimationController _morphController;

  int _currentIndex = 0;
  bool _isDisposed = false;
  bool _animationsEnabled;

  final VoidCallback? _onShapeChange;
  List<ShapeType> _shapeSequence;

  /// Replaces the shape sequence used by the morphing animation.
  ///
  /// The current index is clamped so the indicator keeps morphing from the
  /// shape it is currently on. Passing an empty list restores
  /// [defaultShapeSequence].
  void setShapeSequence(List<ShapeType> sequence) {
    _shapeSequence = sequence.isEmpty
        ? defaultShapeSequence
        : List<ShapeType>.of(sequence);
    _currentIndex = _currentIndex.clamp(0, _shapeSequence.length - 1);
  }

  /// The current shape in the animation sequence.
  ShapeType get currentShape => _shapeSequence[_currentIndex];

  /// The next shape to morph to.
  ShapeType get nextShape =>
      _shapeSequence[(_currentIndex + 1) % _shapeSequence.length];

  /// The current index in the shape sequence.
  int get currentIndex => _currentIndex;

  /// Whether this controller has been disposed.
  bool get isDisposed => _isDisposed;

  /// Whether the rotation and morph animations are currently running.
  bool get isAnimating => _rotationController.isAnimating;

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
    _morphController.forward(from: 0).then((_) {
      if (!_isDisposed) {
        _currentIndex = (_currentIndex + 1) % _shapeSequence.length;
        _onShapeChange?.call();
        _startMorphSequence();
      }
    });
  }

  /// Starts or stops the continuous rotation and morph animations.
  ///
  /// Pass `false` to honor the user's reduced-motion preference: the tickers
  /// stop entirely instead of running unused in the background.
  ///
  /// Setting the value to its current state is a no-op.
  void setAnimationsEnabled({
    required bool enabled,
  }) {
    if (_isDisposed || _animationsEnabled == enabled) return;
    _animationsEnabled = enabled;
    if (enabled) {
      _startAnimations();
    } else {
      _morphController.stop();
      _rotationController.stop();
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _startMorphSequence();
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
