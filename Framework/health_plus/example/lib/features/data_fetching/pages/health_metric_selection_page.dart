// lib/features/data_fetching/views/health_metric_selection_page.dart

import 'package:flutter/material.dart';
import 'data_display_page.dart';

class HealthMetricSelectionPage extends StatelessWidget {
  const HealthMetricSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Health Type")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose a metric to display:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            HealthMetricSelectionButton(healthMetric: "Heart Rate"),
            HealthMetricSelectionButton(healthMetric: "Blood Pressure"),
            HealthMetricSelectionButton(healthMetric: "Stress"),
            HealthMetricSelectionButton(healthMetric: "Steps"),
            HealthMetricSelectionButton(healthMetric: "Sleep"),
          ],
        ),
      ),
    );
  }
}

class HealthMetricSelectionButton extends StatelessWidget {
  final String healthMetric;

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
        child: Text(healthMetric),
      ),
    );
  }
}