// lib/features/data_display/metric_selection_page.dart

import 'package:flutter/material.dart';
import '../../../constants/metrics.dart';
import '../../../constants/metrics_mapper.dart';
import '../data_display/data_display_page.dart';

/// Page for selecting which health metric to view data for
class MetricSelectionPage extends StatelessWidget {
  const MetricSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Metric')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Please make sure all metrics are accepted in Settings',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: HealthMetric.values.length,
                itemBuilder: (context, index) {
                  final metric = HealthMetric.values[index];
                  final label = getMetricLabel(metric);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DataDisplayPage(metric: metric),
                            ),
                          );
                        },
                        child: Text(label),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}