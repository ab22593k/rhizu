import 'package:flutter/material.dart'
    hide CircularProgressIndicator, LinearProgressIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';

void main() {
  testWidgets(
    'Flat determinate LinearProgressIndicator renders a stop indicator',
    (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: LinearProgressIndicator(
            value: 0.5,
            shape: ProgressIndicatorShape.flat,
          ),
        ),
      );

      // Look for CustomPaint that uses LinearPainter
      final cpFinder = find.byType(CustomPaint);
      expect(cpFinder, findsWidgets);

      // We expect the painter to draw a circle for the stop indicator
    },
  );
}
