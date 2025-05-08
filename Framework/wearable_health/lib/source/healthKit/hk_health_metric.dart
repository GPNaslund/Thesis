import 'package:wearable_health/source/health_metric.dart';

enum HealthKitHealthMetric implements HealthMetric {
  heartRate(value: "HKQuantityTypeIdentifierHeartRate"),
  bodyTemperature(value: "HKQuantityTypeIdentifierHeartRate");

  const HealthKitHealthMetric({ required this.value });

  final String value;

  @override
  String get definition => value;

  factory HealthKitHealthMetric.fromString(String input) {
    for (final metric in HealthKitHealthMetric.values) {
      if (metric.value == input) {
        return metric;
      }
    }
    throw UnimplementedError("[HealthKitHealthMetric] Received unknown metric string: $input");
  }
}