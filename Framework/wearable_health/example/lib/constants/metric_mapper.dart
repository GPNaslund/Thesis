// lib/constants/metric_mapper.dart

import 'metrics.dart';
import 'package:wearable_health/provider/enums/health_data_type.dart';

String getMetricLabel(HealthMetric metric) {
  switch (metric) {
    case HealthMetric.heartRate:
      return 'Heart Rate';
    case HealthMetric.skinTemperature:
      return 'Skin Temperature';
    }
}

HealthDataType? mapMetricToHealthDataType(HealthMetric metric) {
  switch (metric) {
    case HealthMetric.heartRate:
      return HealthDataType.heartRate;
    case HealthMetric.skinTemperature:
      return HealthDataType.skinTemperature;
  }
}