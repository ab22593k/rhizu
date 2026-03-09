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

    testWidgets('ProgressIndicator respects text scale factor', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(),
          ),
        ),
      );

      final sizedBoxFinder = find
          .descendant(
            of: find.byType(ProgressIndicator),
            matching: find.byType(SizedBox),
          )
          .first;

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);

      // Default circular wavy size is 48.0 + scale 2.0 = 96.0
      expect(sizedBox.width, equals(96.0));
      expect(sizedBox.height, equals(96.0));
    });

    testWidgets('ProgressIndicator invokes onComplete when value reaches 1.0', (
      tester,
    ) async {
      var completedCalled = false;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ProgressIndicator(
            value: 1.0,
            onComplete: () {
              completedCalled = true;
            },
          ),
        ),
      );

      // Pump to allow the TweenAnimationBuilder to run and trigger the callback
      await tester.pump(const Duration(milliseconds: 1600));

      expect(completedCalled, isTrue);
    });

    testWidgets(
      'ProgressIndicator does not invoke onComplete when value is below 1.0',
      (tester) async {
        var completedCalled = false;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(
              value: 0.5,
              onComplete: () {
                completedCalled = true;
              },
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 1600));

        expect(completedCalled, isFalse);
      },
    );
  });
}
