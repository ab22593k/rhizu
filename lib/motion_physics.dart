/// Material 3 Motion Physics.
///
/// This package provides [SpringDescription] tokens matching the Material 3
/// Expressive Motion specifications.
library;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widget_previews.dart';
import 'package:rhizu/motion_physics.dart';

export 'src/tokens.dart';
export 'src/fallbacks.dart';

@Preview(name: 'Physics Showcase')
Widget physicsShowcasePreview() {
  return const PhysicsShowcase();
}

class PhysicsShowcase extends StatelessWidget {
  const PhysicsShowcase({super.key});

  static final Map<String, SpringDescription> _tokens = {
    'Expressive Fast Spatial': MotionTokens.expressiveFastSpatial,
    'Expressive Fast Effects': MotionTokens.expressiveFastEffects,
    'Expressive Default Spatial': MotionTokens.expressiveDefaultSpatial,
    'Expressive Default Effects': MotionTokens.expressiveDefaultEffects,
    'Expressive Slow Spatial': MotionTokens.expressiveSlowSpatial,
    'Expressive Slow Effects': MotionTokens.expressiveSlowEffects,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: _tokens.entries.map((e) {
            return SpringDemoTile(title: e.key, spring: e.value);
          }).toList(),
        ),
      ),
    );
  }
}

class SpringDemoTile extends StatefulWidget {
  final String title;
  final SpringDescription spring;

  const SpringDemoTile({super.key, required this.title, required this.spring});

  @override
  State<SpringDemoTile> createState() => _SpringDemoTileState();
}

class _SpringDemoTileState extends State<SpringDemoTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _targetValue = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this, value: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _trigger() {
    final start = _controller.value;
    final end = _targetValue;
    final velocity = 0.0;

    final simulation = SpringSimulation(widget.spring, start, end, velocity);

    _controller.animateWith(simulation);

    // Toggle target for next tap
    _targetValue = _targetValue == 0.0 ? 1.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Mass: ${widget.spring.mass}, Stiffness: ${widget.spring.stiffness}, Damping: ${widget.spring.damping.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                FilledButton.tonal(
                  onPressed: _trigger,
                  child: const Text('Animate'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 40,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Align(
                    alignment: Alignment(
                      _controller.value * 2 - 1,
                      0,
                    ), // Map 0..1 to -1..1
                    child: child,
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
