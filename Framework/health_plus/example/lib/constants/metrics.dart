// lib/constants/metrics.dart

// Enum representing all supported health metrics
enum HealthMetric {
  heartRate,
  steps,
}

// Extension to provide display names and keys for enums
extension HealthMetricExtension on HealthMetric {
  String get displayName {
    switch (this) {
      case HealthMetric.heartRate:
        return "Heart Rate";
      case HealthMetric.steps:
        return "Steps";
      //case HealthMetric.heartVariability:
        //return "Heart Variability";
    }
  }

  String get internalKey => name;
}
