import 'package:flutter/material.dart' hide ProgressIndicator;
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/components/indicators/progress.dart';

@Preview(name: 'Progress — Determinate', size: Size(800, 180))
Widget previewProgressDeterminate() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            // Circular wavy 30 %
            ProgressIndicator(value: 0.3),
            // Circular flat 50 %
            ProgressIndicator(
              value: 0.5,
              shape: ProgressIndicatorShape.flat,
            ),
            // Linear wavy 30 %
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                value: 0.3,
                variant: ProgressIndicatorVariant.linear,
                showInlineLabel: true,
                showLabel: true,
              ),
            ),
            // Linear flat 50 %
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                value: 0.5,
                shape: ProgressIndicatorShape.flat,
                variant: .linear,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

@Preview(
  name: 'Progress — Custom wave (amplitude/wavelength)',
  size: Size(800, 180),
)
Widget previewProgressCustomWave() => const MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    body: Center(
      child: Row(
        mainAxisAlignment: .spaceEvenly,
        children: [
          // Circular wavy with a deep, long scallop.
          ProgressIndicator(amplitude: 3.2, wavelength: 30),
          // Linear wavy with a bold 6dp wave; height = 4 + 2×6 = 16dp.
          SizedBox(
            width: 120,
            child: ProgressIndicator(
              value: 0.6,
              variant: ProgressIndicatorVariant.linear,
              amplitude: 6,
              wavelength: 64,
            ),
          ),
          // Linear indeterminate with the default spec wave.
          SizedBox(
            width: 120,
            child: ProgressIndicator(
              variant: ProgressIndicatorVariant.linear,
            ),
          ),
        ],
      ),
    ),
  ),
);

@Preview(name: 'Progress — Indeterminate', size: Size(800, 180))
Widget previewProgressIndeterminate() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            // Circular wavy — spinning wave
            ProgressIndicator(),
            // Circular flat — rotating arc
            ProgressIndicator(shape: ProgressIndicatorShape.flat),
            // Linear wavy — travelling wave
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                variant: ProgressIndicatorVariant.linear,
              ),
            ),
            // Linear flat — sliding bar
            SizedBox(
              width: 120,
              child: ProgressIndicator(
                shape: ProgressIndicatorShape.flat,
                variant: .linear,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
