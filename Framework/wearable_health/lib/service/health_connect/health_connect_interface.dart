import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_connect/enums/hc_availability.dart';

import '../../model/health_connect/enums/hc_health_metric.dart';
import '../../model/health_connect/health_connect_data.dart';

/// Defines interface for interacting with Android's Health Connect API.
/// Provides methods for permission management and health data retrieval.
abstract class HealthConnect {
  /// Checks current permissions for Health Connect metrics.
  /// Returns a list of metrics that the app is authorized to access.
  Future<List<HealthConnectHealthMetric>> checkPermissions();

  /// Retrieves health data for the specified metrics within a time range.
  /// Returns a list of health data records that match the criteria.
  Future<List<HealthConnectData>> getData(
    List<HealthConnectHealthMetric> metrics,
    DateTimeRange timeRange,
  );

  /// Gets the Android platform version.
  /// Useful for compatibility checks.
  Future<String> getPlatformVersion();

  /// Requests permissions for specific health metrics.
  /// Prompts the user with a permission dialog and returns granted permissions.
  Future<List<HealthConnectHealthMetric>> requestPermissions(
    List<HealthConnectHealthMetric> metrics,
  );

  /// Checks if Health Connect is available on the device.
  /// Returns an availability status indicating if and how Health Connect can be accessed.
  Future<HealthConnectAvailability> checkHealthStoreAvailability();
}
