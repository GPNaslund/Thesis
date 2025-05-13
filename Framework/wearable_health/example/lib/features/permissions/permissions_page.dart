// lib/features/permissions/permissions_page.dart

import 'package:flutter/material.dart';
import '../../../constants/metrics.dart';
import '../../../services/wearable_health_service.dart';
import '../data_display/metric_selection_page.dart';
import '../../../services/data_seeding_service.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  final WearableHealthService _wearableHealthService = WearableHealthService();
  bool _requesting = false;

  Future<void> _requestHealthPermissions() async {
    setState(() => _requesting = true);

    try {
      final List<HealthMetric> metrics = List<HealthMetric>.from(HealthMetric.values);
      await _wearableHealthService.requestPermissions(metrics);
    } catch (e) {
      debugPrint("Permission request failed: $e");
    }

    // Optional: Seed mock data
    const bool enableMockSeeding = true;
    if (enableMockSeeding) {
      final seeder = DataSeedingService();
      await seeder.seedMockDataIfAvailable();
    }

    if (!mounted) return;

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