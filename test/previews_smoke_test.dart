import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhizu/src/ui/components/buttons/previews/button_group_previews.dart';
import 'package:rhizu/src/ui/components/buttons/previews/split_button_previews.dart';
import 'package:rhizu/src/ui/components/indicators/morphing.dart';
import 'package:rhizu/src/ui/components/indicators/previews/progress_previews.dart';
import 'package:rhizu/src/ui/components/toolbar/toolbar.dart';

void main() {
  group('previews', () {
    testWidgets('button group preview renders at its viewport size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 280));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buttonGroupStandardPreview());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('split button preview renders at its viewport size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(previewSplitButtonSizes());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('progress previews render at their viewport size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 180));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final preview in [
        previewProgressDeterminate,
        previewProgressCustomWave,
        previewProgressIndeterminate,
      ]) {
        await tester.pumpWidget(preview());
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('morphing loader preview renders at its viewport size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(800, 500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(previewExpressiveLoaderContained());
      // The loader animates forever; one frame is enough to prove layout.
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('toolbar preview renders at its viewport size', (tester) async {
      await tester.binding.setSurfaceSize(const Size(900, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(toolbarPreview());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
