// lib/features/permissions/pages/permission_page.dart

import 'package:flutter/material.dart';
import '../../../services/plugin_service.dart';
import '../../data_fetching/pages/health_metric_selection_page.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  final PluginService _pluginService = PluginService();
  String _statusLabel = "Initializing...";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _handlePermissions();
  }

  Future<void> _handlePermissions() async {
    final granted = await _pluginService.initWithPermissions();
    if (!mounted) return;

    if (granted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HealthMetricSelectionPage()),
      );
    } else {
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
              _statusLabel,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handlePermissions,
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
