import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/indicators/animation/loading_animation_controller.dart';

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
  });
}
