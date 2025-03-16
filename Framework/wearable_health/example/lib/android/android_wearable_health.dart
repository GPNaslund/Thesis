import 'package:flutter/material.dart';
import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/backend/health_data_backend.dart';
import 'package:wearable_health/services/data_transformer/health_data_transformer.dart';
import 'package:wearable_health/services/enums/battery_level.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';
import 'package:wearable_health/services/enums/network_type.dart';
import 'package:wearable_health/services/synchronization/sync_config.dart';
import 'package:wearable_health/wearable_health.dart';
import 'package:wearable_health_example/android/permission_test_widget.dart';

import 'data_collection_widget.dart';

class AndroidWearableHealth extends StatefulWidget {
  const AndroidWearableHealth({super.key});

  @override
  State<AndroidWearableHealth> createState() => _AndroidWearableHealthState();
}

class _AndroidWearableHealthState extends State<AndroidWearableHealth> {
  final WearableHealth _wearableHealthPlugin = WearableHealth.forHealthConnect(
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

  String _permissionStatus = "Not requested";
  bool _hasPermissions = false;
  bool _isCurrentlyCollecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wearable Health Test')),
      body: Column(
        children: [
          Expanded(
            child: PermissionTestWidget(
              wearableHealthPlugin: _wearableHealthPlugin,
              permissionStatus: _permissionStatus,
              onPermissionStatusChange: (status, hasPermissions) {
                setState(() {
                  _permissionStatus = status;
                  _hasPermissions = hasPermissions;
                });
              },
            ),
          ),
          Expanded(
            child: DataCollectionWidget(
              wearableHealthPlugin: _wearableHealthPlugin,
              isEnabled: _hasPermissions,
              isCollecting: _isCurrentlyCollecting,
              onCollectionStateChange: (isCollecting) {
                setState(() {
                  _isCurrentlyCollecting = isCollecting;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}