import 'package:flutter/material.dart';
import 'package:wearable_health_example/placeholder.dart';

class PerformanceModule extends StatelessWidget {
  final Map<String, dynamic>? data;

  const PerformanceModule({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return PlaceholderModule(
        message: 'Run an experiment to see performance metrics',
        icon: Icons.speed,
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed, size: 64, color: Colors.purple),
            const SizedBox(height: 16),
            Text(
              'Performance Module\nTotal time: ${data!['totalTimeMs']}ms',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder for the full Performance Module widget\nthat would be implemented in a separate file.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
