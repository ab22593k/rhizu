import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/components/buttons/split_button.dart';

@Preview(name: 'Split Button - Sizes', size: Size(800, 500))
Widget previewSplitButtonSizes() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: [
            SplitButton(
              size: SplitButtonSize.xs,
              label: 'XS',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              size: SplitButtonSize.sm,
              label: 'Small',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              label: 'Medium',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              size: SplitButtonSize.lg,
              label: 'Large',
              onPressed: () {},
              items: const [],
            ),
            SplitButton(
              size: SplitButtonSize.xl,
              label: 'Extra Large',
              onPressed: () {},
              items: const [],
            ),
          ],
        ),
      ),
    ),
  );
}
