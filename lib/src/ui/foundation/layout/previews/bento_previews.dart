import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'package:rhizu/src/ui/foundation/layout/bento.dart';

@Preview(name: 'Bento Grid Dashboard')
Widget bentoGridDashboard() {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: BentoGrid(
        itemCount: 6,
        itemBuilder: (context, index) {
          final colors = [
            Colors.orange,
            Colors.purple,
            Colors.teal,
            Colors.indigo,
            Colors.red,
            Colors.green,
          ];
          return Container(
            decoration: BoxDecoration(
              color: colors[index % colors.length].withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Tile $index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
        spanBuilder: (index) => switch (index) {
          0 => const BentoSpan(crossAxis: 2, mainAxis: 2),
          1 => const BentoSpan(crossAxis: 2),
          2 => const BentoSpan(mainAxis: 2),
          _ => const BentoSpan(),
        },
      ),
    ),
  );
}
