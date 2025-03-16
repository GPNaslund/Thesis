import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/wearable_health.dart';

class PermissionTestWidget extends StatefulWidget {
  final WearableHealth wearableHealthPlugin;
  final String permissionStatus;
  final Function(String status, bool hasPermissions) onPermissionStatusChange;

  const PermissionTestWidget({
    Key? key,
    required this.wearableHealthPlugin,
    required this.permissionStatus,
    required this.onPermissionStatusChange,
  }) : super(key: key);

  @override
  State<PermissionTestWidget> createState() => _PermissionTestWidgetState();
}

class _PermissionTestWidgetState extends State<PermissionTestWidget> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await widget.wearableHealthPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _requestHealthPermissions() async {
    print("Starting permission request flow...");
    widget.onPermissionStatusChange("Requesting...", false);

    try {
      print("Sending permission request to native code");
      final bool granted = await widget.wearableHealthPlugin.requestPermissions();
      print("Permission request completed with result: $granted");

      // Add a slight delay to ensure the UI updates
      await Future.delayed(Duration(milliseconds: 100));

      // Force a UI update
      if (mounted) {
        widget.onPermissionStatusChange(granted ? "Granted" : "Denied", granted);
        print("Updated UI state to: ${granted ? "Granted" : "Denied"}");
      }
    } catch (e) {
      print("Error in permission request: $e");
      if (mounted) {
        widget.onPermissionStatusChange("Error: $e", false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Permission Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Running on: $_platformVersion'),
            const SizedBox(height: 10),
            Text('Permission status: ${widget.permissionStatus}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _requestHealthPermissions,
              child: const Text('Request Health Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}