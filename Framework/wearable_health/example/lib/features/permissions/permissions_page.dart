// lib/features/permissions/permissions_page.dart

import 'package:flutter/material.dart';
import '../../../services/wearable_health_service.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  final WearableHealthService _wearableHealthService = WearableHealthService();
  String _statusLabel = "Checking permissions...";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }
  
  Future<void> _checkAndRequestPermissions() async {
    final hasPermission = await _wearableHealthService.hasPermissions();
    if (!mounted) return;

    if (hasPermission) {
      _updateStatus("Permission already granted!");
    } else {
      final granted = await _wearableHealthService.requestPermissions();
      if (!mounted) return;

      if (granted) {
        _updateStatus("Permission granted!");
        Navigator.pop(context, true);
      } else {
        _updateStatus("Permission denied. Please allow access.");
        Navigator.pop(context, false);
      }
    }
  }

  void _updateStatus(String message) {
    setState(() {
      _statusLabel = message;
      _loading = false;
    });
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
              onPressed: _checkAndRequestPermissions,
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
