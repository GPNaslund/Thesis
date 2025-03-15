import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/backend/health_data_backend.dart';
import 'package:wearable_health/services/data_transformer/health_data_transformer.dart';
import 'package:wearable_health/services/enums/battery_level.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';
import 'package:wearable_health/services/enums/network_type.dart';
import 'package:wearable_health/services/synchronization/sync_config.dart';
import 'package:wearable_health/wearable_health.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _permissionStatus = "Not requested";
  final _wearableHealthPlugin = WearableHealth.forHealthConnect(
    AuthConfig.automaticAuth(),
    [HealthDataType.heartRate, HealthDataType.steps],
    HealthDataTransformer.openMHealth(),
    HealthDataBackend.http(
      endpoint: 'https://example.com',
      authHeaders: {'Authorization': 'Bearer your_token'},
      retryAttempts: 3,
    ),
    SyncConfig(
      networkType: NetworkType.wifiOnly,
      batchSize: 100,
      interval: Duration(minutes: 5),
      batteryLevel: BatteryLevel.aboveThirtyPercent,
    ),
    (error) => print(error),
  );

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _wearableHealthPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _requestHealthPermissions() async {
    print("Starting permission request flow...");
    setState(() {
      _permissionStatus = "Requesting...";
    });

    try {
      print("Sending permission request to native code");
      final bool granted = await _wearableHealthPlugin.requestPermissions();
      print("Permission request completed with result: $granted");

      // Add a slight delay to ensure the UI updates
      await Future.delayed(Duration(milliseconds: 100));

      // Force a UI update
      if (mounted) {
        setState(() {
          _permissionStatus = granted ? "Granted" : "Denied";
        });
        print("Updated UI state to: $_permissionStatus");
      }
    } catch (e) {
      print("Error in permission request: $e");
      if (mounted) {
        setState(() {
          _permissionStatus = "Error: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('Permission status: $_permissionStatus\n'),
              ElevatedButton(
                onPressed: _requestHealthPermissions,
                child: const Text('Request Health Permissions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
