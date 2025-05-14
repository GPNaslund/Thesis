import 'metrics.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

String getMetricLabel(HealthMetric metric) {
  switch (metric) {
    case HealthMetric.heartRate:
      return 'Heart Rate';
    case HealthMetric.skinTemperature:
      return 'Skin Temperature';
    case HealthMetric.heartRateVariability:
      return 'Heart Rate Variability';
  }
}

dynamic mapMetricToPlatformMetric(HealthMetric metric, {required bool isAndroid}) {
  if (isAndroid) {
    switch (metric) {
      case HealthMetric.heartRate:
        return HealthConnectHealthMetric.heartRate;
      case HealthMetric.skinTemperature:
        return HealthConnectHealthMetric.skinTemperature;
      case HealthMetric.heartRateVariability:
        return HealthConnectHealthMetric.heartRateVariability;
    }
  } else {
    switch (metric) {
      case HealthMetric.heartRate:
        return HealthKitHealthMetric.heartRate;
      case HealthMetric.skinTemperature:
        return HealthKitHealthMetric.bodyTemperature;
      case HealthMetric.heartRateVariability:
        return HealthKitHealthMetric.heartRateVariability;
    }
  }
  return null;
}
