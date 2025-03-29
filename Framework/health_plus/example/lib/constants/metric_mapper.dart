// lib/constants/metrics_mapper.dart

import 'package:health/health.dart';
import 'metrics.dart';

// Maps each HealthMetric enum to its corresponding HealthDataType
HealthDataType? mapToHealthDataType(HealthMetric metric) {
  switch (metric) {
    case HealthMetric.heartRate:
      return HealthDataType.HEART_RATE;
    case HealthMetric.steps:
      return HealthDataType.STEPS;
  }
}
