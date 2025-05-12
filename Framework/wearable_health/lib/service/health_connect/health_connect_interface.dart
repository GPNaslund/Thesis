import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_connect/enums/hc_availability.dart';

import '../../model/health_connect/enums/hc_health_metric.dart';
import '../../model/health_connect/health_connect_data.dart';

abstract class HealthConnect {
  Future<List<HealthConnectHealthMetric>> checkPermissions();
  Future<List<HealthConnectData>> getData(
    List<HealthConnectHealthMetric> metrics,
    DateTimeRange timeRange,
  );
  Future<String> getPlatformVersion();
  Future<List<HealthConnectHealthMetric>> requestPermissions(
    List<HealthConnectHealthMetric> metrics,
  );
  Future<HealthConnectAvailability> checkHealthStoreAvailability();
}
