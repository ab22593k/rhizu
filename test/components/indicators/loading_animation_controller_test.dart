import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/contracts/indicators/shape_contract.dart';
import 'package:rhizu/src/ui/components/indicators/animation/loading_animation_controller.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';

void main() {
  // The controller's repeat() starts tickers, which requires the scheduler
  // binding; TestVSync is the lightweight TickerProvider from flutter_test.
  TestWidgetsFlutterBinding.ensureInitialized();
  const vsync = TestVSync();

  group('LoadingAnimationController', () {
    test('does not animate when created with animations disabled', () {
      final controller = LoadingAnimationController(
        vsync: vsync,
        animationsEnabled: false,
      );
      controller.dispose();

      expect(controller.isAnimating, isFalse);
    });

    test('starts and stops on setAnimationsEnabled', () {
      final controller = LoadingAnimationController(vsync: vsync);

      // Started by default.
      expect(controller.isAnimating, isTrue);

      controller.setAnimationsEnabled(enabled: false);
      expect(controller.isAnimating, isFalse);

      controller.setAnimationsEnabled(enabled: true);
      expect(controller.isAnimating, isTrue);

      controller.dispose();
    });

    test('uses the default sequence when none is provided', () {
      final controller = LoadingAnimationController(
        vsync: vsync,
        animationsEnabled: false,
      );

      expect(controller.currentShape, equals(defaultShapeSequence.first));
      expect(controller.nextShape, equals(defaultShapeSequence[1]));
      controller.dispose();
    });

    test('uses the default sequence for an empty list', () {
      final controller = LoadingAnimationController(
        vsync: vsync,
        shapeSequence: const [],
        animationsEnabled: false,
      );

      expect(controller.currentShape, equals(defaultShapeSequence.first));
      controller.dispose();
    });

    test('morphs through a custom shape sequence', () {
      final controller = LoadingAnimationController(
        vsync: vsync,
        shapeSequence: const [ShapeType.heart, ShapeType.diamond],
        animationsEnabled: false,
      );

      expect(controller.currentShape, equals(ShapeType.heart));
      expect(controller.nextShape, equals(ShapeType.diamond));
      controller.dispose();
    });

    test('setShapeSequence replaces the sequence in place', () {
      final controller = LoadingAnimationController(
        vsync: vsync,
        shapeSequence: const [ShapeType.heart, ShapeType.diamond],
        animationsEnabled: false,
      );

      controller.setShapeSequence(
        const [ShapeType.circle, ShapeType.triangle],
      );
      expect(controller.currentShape, equals(ShapeType.circle));
      expect(controller.nextShape, equals(ShapeType.triangle));

      // An empty list restores the default sequence.
      controller.setShapeSequence(const []);
      expect(controller.currentShape, equals(defaultShapeSequence.first));
      controller.dispose();
    });

    testWidgets('advances through the custom sequence and wraps', (
      tester,
    ) async {
      final controller = LoadingAnimationController(
        vsync: vsync,
        shapeSequence: const [ShapeType.circle, ShapeType.triangle],
      );

      expect(controller.currentShape, equals(ShapeType.circle));
      expect(controller.nextShape, equals(ShapeType.triangle));

      // The first frame only establishes the ticker start time; a second
      // frame past the morph duration completes the transition.
      await tester.pump();
      await tester.pump(
        LoadingIndicatorConstants.morphDuration +
            const Duration(milliseconds: 50),
      );
      expect(controller.currentShape, equals(ShapeType.triangle));
      expect(controller.nextShape, equals(ShapeType.circle));

      // Another full transition wraps back to the first shape.
      await tester.pump(
        LoadingIndicatorConstants.morphDuration +
            const Duration(milliseconds: 50),
      );
      expect(controller.currentShape, equals(ShapeType.circle));
      expect(controller.nextShape, equals(ShapeType.triangle));

      controller.dispose();
    });

    testWidgets('setShapeSequence clamps the current index', (tester) async {
      final controller = LoadingAnimationController(
        vsync: vsync,
        shapeSequence: const [ShapeType.circle, ShapeType.triangle],
      );

      // Advance to the second shape.
      await tester.pump();
      await tester.pump(
        LoadingIndicatorConstants.morphDuration +
            const Duration(milliseconds: 50),
      );
      expect(controller.currentShape, equals(ShapeType.triangle));

      // A shorter sequence clamps the index back into range.
      controller.setShapeSequence(const [ShapeType.diamond]);
      expect(controller.currentShape, equals(ShapeType.diamond));
      expect(controller.nextShape, equals(ShapeType.diamond));

      controller.dispose();
    });
  });
}
