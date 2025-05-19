// lib/constants/metrics_mapper.dart

import 'metrics.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

/// Returns a better readable label for each health metric
String getMetricLabel(HealthMetric metric) {
  switch (metric) {
    case HealthMetric.heartRateVariability:
      return 'Heart Rate Variability';
    case HealthMetric.heartRate:
      return 'Heart Rate';
  }
}

/// Maps a generic health metric to its platform specific version (Android or iOS)
dynamic mapMetricToPlatformMetric(HealthMetric metric, {required bool isAndroid}) {
  if (isAndroid) {
    switch (metric) {
      case HealthMetric.heartRateVariability:
        return HealthConnectHealthMetric.heartRateVariability;
      case HealthMetric.heartRate:
        return HealthConnectHealthMetric.heartRate;
    }
  } else {
    switch (metric) {
      case HealthMetric.heartRateVariability:
        return HealthKitHealthMetric.heartRateVariability;
      case HealthMetric.heartRate:
        return HealthKitHealthMetric.heartRate;
    }
  }
}
