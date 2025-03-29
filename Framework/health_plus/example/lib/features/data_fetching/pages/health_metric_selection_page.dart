// lib/features/data_fetching/pages/health_metric_selection_page.dart

import 'package:flutter/material.dart';
import 'data_display_page.dart';
import '../../../constants/metrics.dart';

class HealthMetricSelectionPage extends StatelessWidget {
  const HealthMetricSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Health Type")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: HealthMetric.values.map((metric) {
            return HealthMetricSelectionButton(
              healthMetric: metric,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class HealthMetricSelectionButton extends StatelessWidget {
  final HealthMetric healthMetric;

  const HealthMetricSelectionButton({super.key, required this.healthMetric});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DataDisplayPage(dataType: healthMetric)),
          );
        },
        child: Text(healthMetric.displayName),
      ),
    );
  }
}