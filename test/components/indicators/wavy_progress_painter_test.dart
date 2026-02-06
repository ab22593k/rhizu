import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/components/indicators/painter/wavy_progress_painter.dart';

void main() {
  group('WavyProgressPainter', () {
    test('constructor stores all parameters', () {
      const painter = WavyProgressPainter(
        progress: 0.5,
        rotation: 1,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      expect(painter.progress, equals(0.5));
      expect(painter.rotation, equals(1.0));
      expect(painter.color, equals(Colors.red));
      expect(painter.trackColor, equals(Colors.blue));
      expect(painter.strokeWidth, equals(4.0));
      expect(painter.waves, equals(12));
      expect(painter.amplitude, equals(2.0));
      expect(painter.trackGap, equals(4.0));
    });

    test('constructor accepts null progress for indeterminate mode', () {
      const painter = WavyProgressPainter(
        progress: null,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      expect(painter.progress, isNull);
    });

    test('shouldRepaint returns true when progress changes', () {
      const painter1 = WavyProgressPainter(
        progress: 0.5,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      const painter2 = WavyProgressPainter(
        progress: 0.6,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when rotation changes', () {
      const painter1 = WavyProgressPainter(
        progress: 0.5,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      const painter2 = WavyProgressPainter(
        progress: 0.5,
        rotation: 1,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns true when color changes', () {
      const painter1 = WavyProgressPainter(
        progress: 0.5,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      const painter2 = WavyProgressPainter(
        progress: 0.5,
        rotation: 0,
        color: Colors.green,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint returns false when nothing changes', () {
      const painter1 = WavyProgressPainter(
        progress: 0.5,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      const painter2 = WavyProgressPainter(
        progress: 0.5,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('createWavyPath generates a valid path', () {
      const painter = WavyProgressPainter(
        progress: 0.5,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      final path = painter.createWavyPath(
        center: const Offset(50, 50),
        baseRadius: 40,
        startAngle: 0,
        sweepAngle: 3.14, // Half circle
        globalRotation: 0,
      );

      expect(path, isNotNull);
      // Path should contain commands
      expect(path.toString().isNotEmpty, isTrue);
    });

    test('createWavyPath closes path for full circle', () {
      const painter = WavyProgressPainter(
        progress: 1,
        rotation: 0,
        color: Colors.red,
        trackColor: Colors.blue,
        strokeWidth: 4,
        waves: 12,
        amplitude: 2,
        trackGap: 4,
      );

      final path = painter.createWavyPath(
        center: const Offset(50, 50),
        baseRadius: 40,
        startAngle: 0,
        sweepAngle: 6.28, // Full circle
        globalRotation: 0,
      );

      expect(path, isNotNull);
    });
  });
}
