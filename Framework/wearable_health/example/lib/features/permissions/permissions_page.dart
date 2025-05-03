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

  @override
  void initState() {
    super.initState();
    _initNativePermissionsFlow();
  }

  Future<void> _initNativePermissionsFlow() async {
    try {
      await _wearableHealthService.requestPermissions(HealthMetric.values);
    } catch (_) {
    }

    // ONLY IN DEVELOPMENT! TEST SEEDING DATA!
    const bool enableMockSeeding = true; // Can set to false in production
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
