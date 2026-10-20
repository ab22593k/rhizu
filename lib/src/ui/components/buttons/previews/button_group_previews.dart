import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/components/buttons/button_group.dart';

@Preview(name: 'Button Group - Standard', size: Size(800, 280))
Widget buttonGroupStandardPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(body: Center(child: _ButtonGroupPreview())),
  );
}

class _ButtonGroupPreview extends StatefulWidget {
  const _ButtonGroupPreview();

  @override
  State<_ButtonGroupPreview> createState() => _ButtonGroupPreviewState();
}

class _ButtonGroupPreviewState extends State<_ButtonGroupPreview> {
  final Set<ButtonGroupSize> _sizes = {ButtonGroupSize.md};
  Set<int> _colors = {1, 3};
  ViewMode _view = ViewMode.list;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Standard - single select'),
          const SizedBox(height: 12),
          ButtonGroup<ButtonGroupSize>(
            items: const [
              ButtonGroupItem(
                value: ButtonGroupSize.xs,
                label: 'XS',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.sm,
                label: 'S',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.md,
                label: 'M',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.lg,
                label: 'L',
                icon: Icons.done,
              ),
              ButtonGroupItem(
                value: ButtonGroupSize.xl,
                label: 'XL',
                icon: Icons.done,
              ),
            ],
            selected: _sizes,
            onSelectionChanged: (next) => setState(
              () => _sizes
                ..clear()
                ..addAll(next),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Standard - expanded (flexible)'),
          const SizedBox(height: 12),
          SizedBox(
            width: 420,
            child: ButtonGroup<ButtonGroupSize>(
              expanded: true,
              items: const [
                ButtonGroupItem(value: ButtonGroupSize.sm, label: 'S'),
                ButtonGroupItem(value: ButtonGroupSize.md, label: 'M'),
                ButtonGroupItem(value: ButtonGroupSize.lg, label: 'L'),
              ],
              selected: _sizes,
              onSelectionChanged: (next) => setState(
                () => _sizes
                  ..clear()
                  ..addAll(next),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Standard - custom color'),
          const SizedBox(height: 12),
          ButtonGroup<ButtonGroupSize>(
            selectedColor: const Color(0xFF00696D),
            unselectedColor: const Color(0xFFE3F2F2),
            items: const [
              ButtonGroupItem(value: ButtonGroupSize.sm, label: 'S'),
              ButtonGroupItem(value: ButtonGroupSize.md, label: 'M'),
              ButtonGroupItem(value: ButtonGroupSize.lg, label: 'L'),
            ],
            selected: _sizes,
            onSelectionChanged: (next) => setState(
              () => _sizes
                ..clear()
                ..addAll(next),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Standard - overflow menu (narrow)'),
          const SizedBox(height: 12),
          SizedBox(
            width: 260,
            child: ButtonGroup<ButtonGroupSize>(
              overflowMode: ButtonGroupOverflowMode.menu,
              items: const [
                ButtonGroupItem(value: ButtonGroupSize.xs, label: 'XS'),
                ButtonGroupItem(value: ButtonGroupSize.sm, label: 'S'),
                ButtonGroupItem(value: ButtonGroupSize.md, label: 'M'),
                ButtonGroupItem(value: ButtonGroupSize.lg, label: 'L'),
                ButtonGroupItem(value: ButtonGroupSize.xl, label: 'XL'),
              ],
              selected: _sizes,
              onSelectionChanged: (next) => setState(
                () => _sizes
                  ..clear()
                  ..addAll(next),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text('Connected - single select'),
          const SizedBox(height: 12),
          ButtonGroup<ViewMode>(
            variant: ButtonGroupVariant.connected,
            showSelectedIcon: true,
            items: const [
              ButtonGroupItem(
                value: ViewMode.list,
                label: 'List',
                icon: Icons.view_list,
              ),
              ButtonGroupItem(
                value: ViewMode.grid,
                label: 'Grid',
                icon: Icons.grid_view,
              ),
              ButtonGroupItem(
                value: ViewMode.calendar,
                label: 'Calendar',
                icon: Icons.calendar_month,
              ),
            ],
            selected: {_view},
            onSelectionChanged: (next) => setState(() => _view = next.first),
          ),
          const SizedBox(height: 40),
          const Text('Connected - multi select'),
          const SizedBox(height: 12),
          ButtonGroup<int>(
            variant: ButtonGroupVariant.connected,
            multiSelectionEnabled: true,
            emptySelectionAllowed: true,
            items: const [
              ButtonGroupItem(value: 1, label: 'Red'),
              ButtonGroupItem(value: 2, label: 'Green'),
              ButtonGroupItem(value: 3, label: 'Blue'),
            ],
            selected: _colors,
            onSelectionChanged: (next) => setState(() => _colors = next),
          ),
        ],
      ),
    );
  }
}

enum ViewMode { list, grid, calendar }
