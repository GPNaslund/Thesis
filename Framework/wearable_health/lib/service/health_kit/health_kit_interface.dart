import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_kit/enums/hk_availability.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';

/// Defines interface for interacting with iOS's HealthKit API.
/// Provides methods for permission management and health data retrieval.
abstract class HealthKit {
  /// Checks if HealthKit is available on the device.
  /// Returns an availability status indicating if and how HealthKit can be accessed.
  Future<HealthKitAvailability> checkHealthStoreAvailability();

  /// Retrieves health data for the specified metrics within a time range.
  /// Returns a list of health data records that match the criteria.
  Future<List<HealthKitData>> getData(
    List<HealthKitHealthMetric> metrics,
    DateTimeRange timeRange,
  );

  /// Gets the iOS platform version.
  /// Useful for compatibility checks.
  Future<String> getPlatformVersion();

  /// Requests permissions for specific health metrics.
  /// Prompts the user with a permission dialog and returns success status.
  Future<bool> requestPermissions(List<HealthKitHealthMetric> metrics);
}
