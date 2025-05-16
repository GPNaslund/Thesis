// lib/features/permissions/permissions_page.dart

import 'package:flutter/material.dart';
import '../../../constants/metrics.dart';
import '../../../services/wearable_health_service.dart';
import '../data_display/metric_selection_page.dart';
import '../../../services/data_seeding_service.dart';

/// The page responsible for requesting health data permissions
class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  /// Instance of the service that requests permissions from the plugin
  final WearableHealthService _wearableHealthService = WearableHealthService();
  bool _requesting = false;

  /// Handles the full flow of requesting health permissions from the user
  Future<void> _requestHealthPermissions() async {
    setState(() => _requesting = true);

    try {
      /// Get all supported metrics available (taken from enums)
      final List<HealthMetric> metrics = List<HealthMetric>.from(HealthMetric.values);
      /// Request permissions for all metrics
      await _wearableHealthService.requestPermissions(metrics);
    } catch (e) {
      debugPrint("Permission request failed: $e");
    }

    /// Optional feature: seed mock data to help with testing
    const bool enableMockSeeding = true;
    if (enableMockSeeding) {
      final seeder = DataSeedingService();
      await seeder.seedMockDataIfAvailable();
    }

    /// If the widget was disposed during the async call, stop here
    if (!mounted) return;

    /// Navigate to the metric selection screen after permissions are granted
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MetricSelectionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions')),
      body: Center(
        child: _requesting
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _requestHealthPermissions,
          child: const Text('Request Permissions'),
        ),
      ),
    );
  }
}