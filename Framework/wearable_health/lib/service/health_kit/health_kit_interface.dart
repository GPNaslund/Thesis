import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_kit/enums/hk_availability.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';

abstract class HealthKit {
  Future<HealthKitAvailability> checkHealthStoreAvailability();
  Future<List<HealthKitData>> getData(
    List<HealthKitHealthMetric> metrics,
    DateTimeRange timeRange,
  );
  Future<String> getPlatformVersion();
  Future<bool> requestPermissions(List<HealthKitHealthMetric> metrics);
}
