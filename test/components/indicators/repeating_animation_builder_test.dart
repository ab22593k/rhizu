import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('RepeatingAnimationBuilder pumps values', (tester) async {
    double? lastValue;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepeatingAnimationBuilder<double>(
          animatable: Tween<double>(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            lastValue = value;
            return Container();
          },
        ),
      ),
    );

    expect(lastValue, 0.0);

    await tester.pump(const Duration(milliseconds: 500));
    expect(lastValue, 0.5);

    // At 1000ms, it completes one cycle. It might be 0.0 or 1.0 depending on exact frame timing/implementation.
    // We check that it continues looping.
    await tester.pump(const Duration(milliseconds: 1000));
    // Total 1500ms elapsed -> should be around 0.5 into the second cycle
    expect(lastValue, closeTo(0.5, 0.01));
  });
}
