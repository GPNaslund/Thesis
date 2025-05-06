import 'package:wearable_health/source/health_metric.dart';

enum HealthConnectHealthMetric implements HealthMetric {
  heartRate(value: "android.permission.health.READ_HEART_RATE"),
  skinTemperature(value: "android.permission.health.READ_SKIN_TEMPERATURE");

  const HealthConnectHealthMetric({required this.value});

  final String value;

  @override
  String get definition => value;

  factory HealthConnectHealthMetric.fromString(String input) {
    for (final metric in HealthConnectHealthMetric.values) {
      if (metric.value == input) {
        return metric;
      }
    }
    throw UnimplementedError(
      "[HealthConnectHealthMetric] Received unknown metric string: $input",
    );
  }
}
