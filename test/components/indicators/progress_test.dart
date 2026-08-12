import 'dart:ui' as ui;

import 'package:flutter/material.dart'
    hide CircularProgressIndicator, LinearProgressIndicator, ProgressIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';
import 'package:rhizu/src/ui/components/indicators/constants.dart';
import 'package:rhizu/src/ui/components/indicators/progress.dart';

void main() {
  // The stop-dot pixel test uses PictureRecorder/toImageSync, which need the
  // flutter_test binding even when run via --plain-name.
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Progress Indicators compliance tests', () {
    testWidgets(
      'LinearProgressIndicator uses 2000ms animation duration for linear',
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
          equals(const Duration(milliseconds: 2000)),
        );
      },
    );

    testWidgets(
      'CircularProgressIndicator uses (1333 * 2222)ms LCM animation duration for circular',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(),
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
          equals(const Duration(milliseconds: 1333 * 2222)),
        );
      },
    );

    test(
      'specForLinear wavy uses spec wavelengths (40dp / 20dp indeterminate)',
      () {
        final spec = specForLinear(
          size: ProgressIndicatorSize.s,
          shape: ProgressIndicatorShape.wavy,
        );
        expect(spec.wavePeriod, equals(40.0));
        expect(spec.indeterminateWavePeriod, equals(20.0));
        expect(spec.waveAmplitude, equals(3.0));
        expect(spec.gap, equals(4.0));
      },
    );

    test('WavyProgressConstants provides correct defaults', () {
      expect(WavyProgressConstants.defaultWavePeriod, equals(40.0));
      expect(WavyProgressConstants.indeterminateWavePeriod, equals(20.0));
      expect(WavyProgressConstants.circularWaveAmplitude, equals(1.6));
      expect(WavyProgressConstants.circularWavePeriod, equals(15.0));
      expect(
        WavyProgressConstants.rotationDuration,
        equals(const Duration(milliseconds: 1000)),
      );
    });

    testWidgets(
      'ProgressIndicator size is independent of text scale',
      (tester) async {
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

        // Typography settings are not a layout breakpoint: the default
        // circular wavy size (48.0) stays 48.0 at 2x text scale.
        expect(sizedBox.width, equals(48.0));
        expect(sizedBox.height, equals(48.0));
      },
    );

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

    testWidgets(
      'linear track color defaults to secondaryContainer (spec token)',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                child: ProgressIndicator(
                  value: 0.5,
                  variant: ProgressIndicatorVariant.linear,
                ),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 1600));

        final customPaint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(ProgressIndicator),
            matching: find.byType(CustomPaint),
          ),
        );
        final painter = customPaint.painter! as LinearPainter;
        final cs = Theme.of(
          tester.element(find.byType(ProgressIndicator)),
        ).colorScheme;

        expect(painter.track, equals(cs.secondaryContainer));
        expect(painter.active, equals(cs.primary));
      },
    );

    testWidgets(
      'circular track color defaults to secondaryContainer (spec token)',
      (
        tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ProgressIndicator(
                value: 0.5,
                shape: ProgressIndicatorShape.flat,
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 1600));

        final customPaint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(ProgressIndicator),
            matching: find.byType(CustomPaint),
          ),
        );
        final painter = customPaint.painter! as CircularFlatPainter;
        final cs = Theme.of(
          tester.element(find.byType(ProgressIndicator)),
        ).colorScheme;

        expect(painter.track, equals(cs.secondaryContainer));
        expect(painter.active, equals(cs.primary));
      },
    );

    test(
      'stop indicator dot is painted with the active (primary) color',
      () async {
        const active = Color(0xFF006C45);
        const track = Color(0xFFA0F6B3);
        const size = Size(200, 4);
        final painter = LinearPainter(
          value: 0.5,
          spec: specForLinear(
            size: ProgressIndicatorSize.s,
            shape: ProgressIndicatorShape.flat,
          ),
          active: active,
          track: track,
          phase: 0.0,
          inset: 4.0,
          path: Path(),
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        painter.paint(canvas, size);
        final picture = recorder.endRecording();

        // Spec: stop-indicator.color = primary. The dot sits at the end of the
        // track: right + gap + dot⌀/2, on the track centerline.
        final dotCenterX =
            size.width -
            painter.spec.trailingMargin +
            painter.spec.gap +
            painter.spec.dotDiameter / 2;
        final dotCenterY = size.height / 2 + painter.spec.dotVerticalOffset;

        final image = picture.toImageSync(
          size.width.toInt(),
          size.height.toInt(),
        );
        final data = await image.toByteData();
        picture.dispose();
        image.dispose();

        final offset =
            (dotCenterY.toInt() * size.width.toInt() + dotCenterX.toInt()) * 4;
        final r = data!.getUint8(offset);
        final g = data.getUint8(offset + 1);
        final b = data.getUint8(offset + 2);
        final a = data.getUint8(offset + 3);

        // The dot must render in the primary (active) color, not the track color.
        final rendered = Color.fromARGB(a, r, g, b);
        expect(rendered, equals(active));
        expect(rendered, isNot(equals(track)));
      },
    );

    testWidgets('onComplete still fires under reduced motion', (tester) async {
      var completedCalled = false;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(
              value: 1.0,
              onComplete: () {
                completedCalled = true;
              },
            ),
          ),
        ),
      );

      expect(completedCalled, isTrue);
    });

    testWidgets('respects reduced motion for determinate value', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(value: 0.7),
          ),
        ),
      );

      // No repeating animation builder and no TweenAnimationBuilder should be
      // present; the value renders statically.
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('respects reduced motion for indeterminate circular', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(),
          ),
        ),
      );

      expect(find.byType(RepeatingAnimationBuilder<double>), findsNothing);
    });

    testWidgets('respects reduced motion for indeterminate linear', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(
              variant: ProgressIndicatorVariant.linear,
            ),
          ),
        ),
      );

      expect(find.byType(RepeatingAnimationBuilder<double>), findsNothing);
    });
  });

  group('Inline Value Label (linear)', () {
    testWidgets('no label shown by default', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 200,
            child: ProgressIndicator(
              value: 0.5,
              variant: ProgressIndicatorVariant.linear,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1600));

      // No Text widget showing a percentage
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('shows percentage text when showInlineLabel is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 200,
            child: ProgressIndicator(
              value: 0.5,
              variant: ProgressIndicatorVariant.linear,
              showInlineLabel: true,
            ),
          ),
        ),
      );

      // Let the spring animation settle
      await tester.pump(const Duration(milliseconds: 1600));

      expect(find.textContaining('50%'), findsOneWidget);
    });

    testWidgets('label is hidden in indeterminate mode', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 200,
            child: ProgressIndicator(
              variant: ProgressIndicatorVariant.linear,
              showInlineLabel: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // No label in indeterminate mode
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('label shows 100% at full progress', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 200,
            child: ProgressIndicator(
              value: 1.0,
              variant: ProgressIndicatorVariant.linear,
              showInlineLabel: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1600));

      expect(find.textContaining('100%'), findsOneWidget);
    });

    testWidgets('label tracks progress position horizontally', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 300,
            child: ProgressIndicator(
              value: 0.5,
              variant: ProgressIndicatorVariant.linear,
              showInlineLabel: true,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1600));

      // The label widget should exist
      final labelFinder = find.textContaining('50%');
      expect(labelFinder, findsOneWidget);

      // The label's horizontal center should be roughly at 50% of the width
      final labelBox = tester.getRect(labelFinder);
      final containerBox = tester.getRect(
        find.byType(ProgressIndicator),
      );
      final labelCenter = labelBox.center.dx;
      final expectedCenter = containerBox.left + containerBox.width * 0.5;

      // Allow some tolerance for padding/inset
      expect(labelCenter, closeTo(expectedCenter, 30));
    });
  });
}
