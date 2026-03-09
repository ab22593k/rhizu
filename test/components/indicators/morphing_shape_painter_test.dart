import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/indicators/painter/morphing_shape_painter.dart';
import 'package:rhizu/src/ui/components/indicators/shapes/shape_type.dart';

void main() {
  test('MorphingShapePainter accepts scale parameter', () {
    final painter = MorphingShapePainter(
      color: Colors.blue,
      currentShape: ShapeType.softBurst,
      nextShape: ShapeType.cookie9,
      progress: 0.5,
      rotation: 0,
      path: Path(),
      points: List<Offset>.filled(121, Offset.zero),
      scale: 2.0,
    );

    expect(painter.scale, equals(2.0));
  });

  test('MorphingShapePainter triggers repaint when scale changes', () {
    final painter1 = MorphingShapePainter(
      color: Colors.blue,
      currentShape: ShapeType.softBurst,
      nextShape: ShapeType.cookie9,
      progress: 0.5,
      rotation: 0,
      path: Path(),
      points: List<Offset>.filled(121, Offset.zero),
    );

    final painter2 = MorphingShapePainter(
      color: Colors.blue,
      currentShape: ShapeType.softBurst,
      nextShape: ShapeType.cookie9,
      progress: 0.5,
      rotation: 0,
      path: Path(),
      points: List<Offset>.filled(121, Offset.zero),
      scale: 2.0,
    );

    expect(painter1.shouldRepaint(painter2), isTrue);
    expect(painter2.shouldRepaint(painter1), isTrue);
  });

  test('MorphingShapePainter does not trigger repaint when scale is same', () {
    final painter1 = MorphingShapePainter(
      color: Colors.blue,
      currentShape: ShapeType.softBurst,
      nextShape: ShapeType.cookie9,
      progress: 0.5,
      rotation: 0,
      path: Path(),
      points: List<Offset>.filled(121, Offset.zero),
    );

    final painter2 = MorphingShapePainter(
      color: Colors.blue,
      currentShape: ShapeType.softBurst,
      nextShape: ShapeType.cookie9,
      progress: 0.5,
      rotation: 0,
      path: Path(),
      points: List<Offset>.filled(121, Offset.zero),
    );

    expect(painter1.shouldRepaint(painter2), isFalse);
  });
}
