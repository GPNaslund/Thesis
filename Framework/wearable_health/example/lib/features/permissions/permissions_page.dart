// lib/features/permissions/permissions_page.dart

import 'package:flutter/material.dart';
import '../../../constants/metrics.dart';
import '../../../services/wearable_health_service.dart';
import '../data_display/metric_selection_page.dart';

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
