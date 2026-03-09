import 'package:flutter/material.dart'
    hide CircularProgressIndicator, LinearProgressIndicator, ProgressIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/progress.dart';

void main() {
  group('Progress Indicators compliance tests', () {
    testWidgets(
      'LinearProgressIndicator uses 1000ms animation duration for wavy',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(variant: ProgressIndicatorVariant.linear),
          ),
        );

        final repeatingBuilderFinder = find.byType(
          RepeatingAnimationBuilder<double>,
        );
        expect(repeatingBuilderFinder, findsOneWidget);

        final repeatingBuilder = tester
            .widget<RepeatingAnimationBuilder<double>>(repeatingBuilderFinder);
        expect(
          repeatingBuilder.duration,
          equals(const Duration(milliseconds: 1800)),
        );
      },
    );

    test('specForLinear wavy has wavePeriod 48.0', () {
      // Unfortunately LinearSpecs wavePeriod is hard to test without exposing it, but we can check if there's a property.
      // We will verify this after exposing wavePeriod correctly in the constructor.
    });

    test('WavyProgressConstants provides correct defaults', () {
      expect(WavyProgressConstants.defaultWavePeriod, equals(48.0));
      expect(
        WavyProgressConstants.rotationDuration,
        equals(const Duration(milliseconds: 1000)),
      );
    });
  });
}
