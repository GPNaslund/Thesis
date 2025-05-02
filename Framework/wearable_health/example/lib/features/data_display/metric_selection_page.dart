// lib/features/metrics/metric_selection_page.dart

import 'package:flutter/material.dart';
import '../../../services/wearable_health_service.dart';
import '../../../constants/metrics.dart';
import '../../../constants/metric_mapper.dart';
import '../data_display/data_display_page.dart';

class MetricSelectionPage extends StatelessWidget {
  const MetricSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = WearableHealthService();

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Metric')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: HealthMetric.values.map((metric) {
            final label = getMetricLabel(metric);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  final granted = await service.hasPermission(metric);

                  if (granted && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataDisplayPage(metric: metric),
                      ),
                    );
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Permission not granted for $label.\nPlease allow it in Settings.',
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Text(label),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
