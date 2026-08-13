import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart'
    hide CircularProgressIndicator, LinearProgressIndicator, ProgressIndicator;
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/rhizu.dart';
import 'package:rhizu/src/ui/components/indicators/animation/indeterminate_arc_motion.dart';
import 'package:rhizu/src/ui/components/indicators/animation/linear_indeterminate_motion.dart';
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

    Future<Color> pixelAt(
      ui.Picture picture,
      Size size,
      int x,
      int y,
    ) async {
      final image = picture.toImageSync(
        size.width.toInt(),
        size.height.toInt(),
      );
      final data = await image.toByteData();
      image.dispose();
      final offset = (y * size.width.toInt() + x) * 4;
      return Color.fromARGB(
        data!.getUint8(offset + 3),
        data.getUint8(offset),
        data.getUint8(offset + 1),
        data.getUint8(offset + 2),
      );
    }

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
          textDirection: TextDirection.ltr,
          path: Path(),
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        painter.paint(canvas, size);
        final picture = recorder.endRecording();

        // Spec: stop-indicator.color = primary. Reference placement: dot center
        // at (size.width - maxRadius, maxRadius) where maxRadius = height/2.
        final dotCenterX = size.width - size.height / 2;
        final dotCenterY = size.height / 2;

        final rendered = await pixelAt(
          picture,
          size,
          dotCenterX.toInt(),
          dotCenterY.toInt(),
        );
        picture.dispose();

        // The dot must render in the primary (active) color, not the track color.
        expect(rendered, equals(active));
        expect(rendered, isNot(equals(track)));
      },
    );

    test(
      'stop dot is centered and leaves 2dp trailing space for the 8dp sample',
      () async {
        const active = Color(0xFF006C45);
        const track = Color(0xFFA0F6B3);
        // Medium/thick linear: 8dp height, 4dp dot → radius 2 clamped to
        // height/2 = 4, center at (width - 4, 4).
        const size = Size(200, 8);
        final painter = LinearPainter(
          value: 0.5,
          spec: specForLinear(
            size: ProgressIndicatorSize.m,
            shape: ProgressIndicatorShape.flat,
          ),
          active: active,
          track: track,
          phase: 0.0,
          inset: 4.0,
          textDirection: TextDirection.ltr,
          path: Path(),
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        painter.paint(canvas, size);
        final picture = recorder.endRecording();

        // Center of the dot: (width - height/2, height/2) = (196, 4).
        final center = await pixelAt(picture, size, 196, 4);
        // Trailing space: 2dp right of the dot edge (dot spans to x = 198)
        // still shows the track, not the dot.
        final trailing = await pixelAt(picture, size, 199, 4);
        picture.dispose();

        expect(center, equals(active));
        expect(trailing, equals(track));
      },
    );

    test(
      'determinateWaveAmplitudeFactor follows the reference amplitude ramp',
      () {
        // Reference (`WavyProgressIndicatorDefaults.indicatorAmplitude`): the
        // wave is flat below 10% and above 95% progress and full in between, so
        // short arcs (e.g. value=4%) keep the spec 4dp gap crisp instead of
        // looking detached from the track.
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.0),
          equals(0.0),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.04),
          equals(0.0),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.10),
          equals(0.0),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.5),
          equals(1.0),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.95),
          equals(0.0),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(1.0),
          equals(0.0),
        );
        // Smooth transition bands (10–12% and 93–95%) approximate the
        // reference's animated amplitude instead of a hard pop.
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.11),
          closeTo(0.5, 1e-9),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.12),
          closeTo(1.0, 1e-9),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.93),
          closeTo(1.0, 1e-9),
        );
        expect(
          WavyProgressConstants.determinateWaveAmplitudeFactor(0.94),
          closeTo(0.5, 1e-9),
        );
      },
    );

    Future<Uint8List> renderToBytes(CustomPainter painter, Size size) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, size);
      final picture = recorder.endRecording();
      final image = picture.toImageSync(
        size.width.toInt(),
        size.height.toInt(),
      );
      final data = (await image.toByteData())!;
      picture.dispose();
      image.dispose();
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }

    test('circular wavy is phase-invariant (flat) at value=4%', () async {
      const active = Color(0xFF006C45);
      const track = Color(0xFFA0F6B3);
      const size = Size(48, 48);
      final phase0 = CircularWavyPainter(
        value: 0.04,
        active: active,
        track: track,
        rotation: 0.0,
        size: ProgressIndicatorSize.s,
        path: Path(),
      );
      final phasePi = CircularWavyPainter(
        value: 0.04,
        active: active,
        track: track,
        rotation: 0.0,
        size: ProgressIndicatorSize.s,
        path: Path(),
        wavePhase: math.pi,
      );

      final a = await renderToBytes(phase0, size);
      final b = await renderToBytes(phasePi, size);

      // Below the 10% amplitude ramp the wave is flat, so shifting the wave
      // phase must not change a single rendered pixel. The old full-amplitude
      // wave changed crest/trough positions with the phase.
      expect(a, orderedEquals(b));
    });

    test('circular wavy is phase-dependent (wavy) at mid progress', () async {
      const active = Color(0xFF006C45);
      const track = Color(0xFFA0F6B3);
      const size = Size(48, 48);
      final phase0 = CircularWavyPainter(
        value: 0.5,
        active: active,
        track: track,
        rotation: 0.0,
        size: ProgressIndicatorSize.s,
        path: Path(),
      );
      final phasePi = CircularWavyPainter(
        value: 0.5,
        active: active,
        track: track,
        rotation: 0.0,
        size: ProgressIndicatorSize.s,
        path: Path(),
        wavePhase: math.pi,
      );

      final a = await renderToBytes(phase0, size);
      final b = await renderToBytes(phasePi, size);

      // Mid progress has full wave amplitude, so the phase genuinely moves the
      // wave — proving the phase-invariance test above would catch a regression
      // to the old always-wavy behavior.
      expect(a, isNot(orderedEquals(b)));
    });

    test('linear wavy is phase-invariant (flat) at value=4%', () async {
      const active = Color(0xFF006C45);
      const track = Color(0xFFA0F6B3);
      const size = Size(200, 10);
      final spec = specForLinear(
        size: ProgressIndicatorSize.s,
        shape: ProgressIndicatorShape.wavy,
      );
      final phase0 = LinearPainter(
        value: 0.04,
        spec: spec,
        active: active,
        track: track,
        phase: 0.0,
        inset: 4.0,
        textDirection: TextDirection.ltr,
        path: Path(),
      );
      final phasePi = LinearPainter(
        value: 0.04,
        spec: spec,
        active: active,
        track: track,
        phase: math.pi,
        inset: 4.0,
        textDirection: TextDirection.ltr,
        path: Path(),
      );

      final a = await renderToBytes(phase0, size);
      final b = await renderToBytes(phasePi, size);
      expect(a, orderedEquals(b));
    });

    testWidgets(
      'wavy determinate skips wave animation when the wave is flat (value=4%)',
      (tester) async {
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: ProgressIndicator(value: 0.04),
          ),
        );
        await tester.pump(const Duration(milliseconds: 1600));

        // The reference only runs the wave animation while the amplitude is
        // positive; at 4% the wave is flat so no repeating animation is needed.
        expect(find.byType(RepeatingAnimationBuilder<double>), findsNothing);
      },
    );

    testWidgets('wavy determinate animates the wave at mid progress', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ProgressIndicator(value: 0.5),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1600));

      expect(find.byType(RepeatingAnimationBuilder<double>), findsOneWidget);
    });

    test('circular determinate track gap is stroke-inclusive', () async {
      const active = Color(0xFF006C45);
      const track = Color(0xFFA0F6B3);
      // Flat small: 40dp container, 4dp stroke → radius (40-4)/2 = 18.
      const size = Size(40, 40);
      final painter = CircularFlatPainter(
        value: 0.5,
        active: active,
        track: track,
        rotation: 0.0,
        size: ProgressIndicatorSize.s,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, size);
      final picture = recorder.endRecording();

      // The active arc spans top → bottom (value 0.5). The track gap is
      // stroke-inclusive (reference `startGap = strokeRadius + gapRadius`):
      // the round caps of both arcs must leave a real visible gap instead of
      // touching, so the midpoint of the gap (≈ angle π/2 + 0.22rad) is
      // background, while the far side of the circle still shows the track.
      final gapPixel = await pixelAt(picture, size, 16, 38);
      final trackPixel = await pixelAt(picture, size, 2, 20);
      picture.dispose();

      expect(gapPixel, isNot(equals(active)));
      expect(gapPixel, isNot(equals(track)));
      expect(trackPixel, equals(track));
    });

    test(
      'circular indeterminate track gap is stroke-inclusive (flat)',
      () async {
        const active = Color(0xFF006C45);
        const track = Color(0xFFA0F6B3);
        // Flat small: 40dp container, 4dp stroke → radius (40-4)/2 = 18.
        const size = Size(40, 40);
        final painter = CircularFlatPainter(
          value: null,
          active: active,
          track: track,
          rotation: 0.0,
          size: ProgressIndicatorSize.s,
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        painter.paint(canvas, size);
        final picture = recorder.endRecording();

        // Indeterminate at rotation 0: the active arc is the min 15° sweep from
        // the top (start −π/2, end ≈ −1.309). The track resumes at
        // end + gapAngle with a stroke-inclusive gap ((4 + 4)/18 rad) so the
        // round caps leave a real 4dp gap; its midpoint sits at angle
        // end + gapAngle/2 (≈ −1.087), radius 18 → pixel (28, 4) and (28, 3).
        final gapPixel = await pixelAt(picture, size, 28, 4);
        final gapPixel2 = await pixelAt(picture, size, 28, 3);
        final activePixel = await pixelAt(picture, size, 20, 2);
        final trackPixel = await pixelAt(picture, size, 35, 10);
        picture.dispose();

        expect(gapPixel, isNot(equals(active)));
        expect(gapPixel, isNot(equals(track)));
        expect(gapPixel2, isNot(equals(active)));
        expect(gapPixel2, isNot(equals(track)));
        expect(activePixel, equals(active));
        expect(trackPixel, equals(track));
      },
    );

    test(
      'circular indeterminate track gap is stroke-inclusive (wavy)',
      () async {
        const active = Color(0xFF006C45);
        const track = Color(0xFFA0F6B3);
        // Wavy small: 48dp container, 4dp stroke, 1.6dp amplitude →
        // baseRadius (48-4)/2 - 1.6 = 20.4.
        const size = Size(48, 48);
        final painter = CircularWavyPainter(
          value: null,
          active: active,
          track: track,
          rotation: 0.0,
          size: ProgressIndicatorSize.s,
          path: Path(),
        );

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        painter.paint(canvas, size);
        final picture = recorder.endRecording();

        // Indeterminate at rotation 0 with zero wave phase: the active arc is
        // the min 15° sweep from the top. The stroke-inclusive gap angle
        // ((4 + 4)/20.4 rad) leaves an angular window empty at every radius;
        // probing its midpoint at radius 19 must show neither color.
        const stroke = 4.0;
        final baseRadius =
            (math.min(size.width, size.height) - stroke) / 2 -
            WavyProgressConstants.circularWaveAmplitude;
        final gapAngle =
            (stroke + WavyProgressConstants.defaultTrackGap) / baseRadius;
        final (start, sweep) = IndeterminateArcMotion.compute(0.0);
        final midAngle = start + sweep + gapAngle / 2;
        final probeX = 24 + (19.0 * math.cos(midAngle)).round();
        final probeY = 24 + (19.0 * math.sin(midAngle)).round();

        final gapPixel = await pixelAt(picture, size, probeX, probeY);
        final activePixel = await pixelAt(picture, size, 27, 2);
        final trackPixel = await pixelAt(picture, size, 42, 16);
        picture.dispose();

        expect(gapPixel, isNot(equals(active)));
        expect(gapPixel, isNot(equals(track)));
        expect(activePixel, equals(active));
        expect(trackPixel, equals(track));
      },
    );

    test('effectiveTrackGapFraction scales from 0 to full by 1%', () {
      const gapFraction = 4.0 / 196.0;
      expect(
        LinearPainter.effectiveTrackGapFraction(0.0, gapFraction),
        equals(0.0),
      );
      expect(
        LinearPainter.effectiveTrackGapFraction(0.005, gapFraction),
        closeTo(gapFraction * 0.5, 1e-9),
      );
      expect(
        LinearPainter.effectiveTrackGapFraction(0.01, gapFraction),
        closeTo(gapFraction, 1e-9),
      );
      expect(
        LinearPainter.effectiveTrackGapFraction(0.5, gapFraction),
        closeTo(gapFraction, 1e-9),
      );
    });

    test('linear determinate track gap is stroke-inclusive', () async {
      const active = Color(0xFF006C45);
      const track = Color(0xFFA0F6B3);
      // Flat small: 4dp stroke, 4dp spec gap, 4px-tall lane on a 200×4 canvas.
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
        textDirection: TextDirection.ltr,
        path: Path(),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, size);
      final picture = recorder.endRecording();

      // Active ends at inset + 0.5*196 = 102; its round cap reaches 104. With a
      // stroke-inclusive gap (102 + 4 gap + 4 stroke = 110) the track's cap
      // starts at 108, leaving a real 4dp gap ([104, 108]) at the centerline
      // instead of the caps touching.
      final gapPixel = await pixelAt(picture, size, 106, 2);
      final activePixel = await pixelAt(picture, size, 100, 2);
      final trackPixel = await pixelAt(picture, size, 160, 2);
      picture.dispose();

      expect(gapPixel, isNot(equals(active)));
      expect(gapPixel, isNot(equals(track)));
      expect(activePixel, equals(active));
      expect(trackPixel, equals(track));
    });

    test('linear indeterminate track gap is stroke-inclusive', () async {
      const active = Color(0xFF006C45);
      const track = Color(0xFFA0F6B3);
      // A wide canvas so the 4dp visual gap occupies whole pixels.
      const size = Size(400, 4);
      final spec = specForLinear(
        size: ProgressIndicatorSize.s,
        shape: ProgressIndicatorShape.flat,
      );
      // t = 0.25: line 1 is sweeping (tail started, head halfway), line 2 is
      // still collapsed — exactly the two-piece track layout to inspect.
      final (line1Start, line1End, _, _) = LinearIndeterminateMotion.compute(
        0.25,
      );
      final painter = LinearPainter(
        value: null,
        spec: spec,
        active: active,
        track: track,
        phase: 0.25 * 2 * math.pi,
        inset: 4.0,
        textDirection: TextDirection.ltr,
        path: Path(),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, size);
      final picture = recorder.endRecording();

      final width = size.width - 4.0; // inset
      // Stroke-inclusive gap: both active round caps extend stroke/2, so the
      // midpoint of the real 4dp visible gap sits exactly 4dp past each line 1
      // endpoint (gap + stroke − stroke = gap).
      final headGapMidX = 4.0 + line1End * width + 4.0;
      final tailGapMidX = 4.0 + line1Start * width - 4.0;
      final headBodyX = 4.0 + line1End * width - 1.0;

      final headGapPixel = await pixelAt(picture, size, headGapMidX.toInt(), 2);
      final tailGapPixel = await pixelAt(picture, size, tailGapMidX.toInt(), 2);
      final headPixel = await pixelAt(picture, size, headBodyX.toInt(), 2);
      picture.dispose();

      expect(headGapPixel, isNot(equals(active)));
      expect(headGapPixel, isNot(equals(track)));
      expect(tailGapPixel, isNot(equals(active)));
      expect(tailGapPixel, isNot(equals(track)));
      expect(headPixel, equals(active));
    });

    test('determinate linear indicator is mirrored for RTL', () async {
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
        textDirection: TextDirection.rtl,
        path: Path(),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, size);
      final picture = recorder.endRecording();

      // RTL: active indicator fills from the right edge, stop dot sits on the
      // left edge at (maxRadius, maxRadius) = (2, 2).
      final dot = await pixelAt(picture, size, 2, 2);
      final leftActive = await pixelAt(picture, size, 150, 2);
      final rightTrack = await pixelAt(picture, size, 10, 2);
      picture.dispose();

      expect(dot, equals(active));
      expect(leftActive, equals(active));
      expect(rightTrack, equals(track));
    });

    testWidgets('determinate indicator exposes progress-bar semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ProgressIndicator(
            value: 0.5,
            variant: ProgressIndicatorVariant.linear,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1600));

      final semantics = tester.getSemantics(find.byType(ProgressIndicator));
      expect(semantics.role, equals(SemanticsRole.progressBar));
      expect(semantics.value, equals('50'));
    });

    testWidgets('indeterminate indicator exposes loading-spinner semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: ProgressIndicator(),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ProgressIndicator));
      expect(semantics.role, equals(SemanticsRole.loadingSpinner));
    });

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
