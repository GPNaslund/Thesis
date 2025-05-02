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
  String _statusLabel = "Checking permissions...";
  bool _loading = true;
  bool _hasRetried = false;

  @override
  void initState() {
    super.initState();
    _requestAllPermissions();
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _loading = true);

    final result = await _wearableHealthService.requestPermissions(HealthMetric.values);
    if (!mounted) return;

    if (result.grantedMetrics.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MetricSelectionPage(grantedMetrics: result.grantedMetrics),
        ),
      );
    } else {
      if (!_hasRetried) {
        _hasRetried = true;
        await Future.delayed(const Duration(milliseconds: 500));
        _requestAllPermissions();
        return;
      }
      setState(() {
        _statusLabel = "Permissions denied. Please allow access to continue.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Permissions")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please adjust permissions in Settings',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
