// lib/features/metrics/metric_selection_page.dart

import 'package:flutter/material.dart';
import '../../../constants/metrics.dart';
import '../../../constants/metric_mapper.dart';
import '../data_display/data_display_page.dart';

class MetricSelectionPage extends StatelessWidget {
  final List<HealthMetric> grantedMetrics;

  const MetricSelectionPage({super.key, required this.grantedMetrics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Metric')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: grantedMetrics.isEmpty
            ? const Center(child: Text("No metrics granted."))
            : Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: grantedMetrics.map((metric) {
              final label = getMetricLabel(metric);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DataDisplayPage(metric: metric),
                      ),
                    );
                  },
                  child: Text(label),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
