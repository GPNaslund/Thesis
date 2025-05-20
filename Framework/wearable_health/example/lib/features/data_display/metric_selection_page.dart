// lib/features/data_display/metric_selection_page.dart

import 'package:flutter/material.dart';
import '../../../constants/metrics.dart';
import '../../../constants/metrics_mapper.dart';
import '../data_display/data_display_page.dart';
import '../../../services/wearable_health_service.dart';

/// Page for selecting which health metric to view data for
class MetricSelectionPage extends StatefulWidget {
  const MetricSelectionPage({super.key});

  @override
  State<MetricSelectionPage> createState() => _MetricSelectionPageState();
}

class _MetricSelectionPageState extends State<MetricSelectionPage> {
  final WearableHealthService _wearableHealthService = WearableHealthService();
  bool _redirecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Metric')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const Text(
                  'Please ensure all metrics are accepted in app settings:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _redirecting
                        ? null
                        : () async {
                      setState(() => _redirecting = true);
                      final success = await _wearableHealthService.redirectToPermissionsSettings();
                      setState(() => _redirecting = false);
                      if (!success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("⚠️ Failed to open settings.")),
                        );
                      }
                    },
                    child: Text(_redirecting ? 'Opening Settings...' : 'Open Settings'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
