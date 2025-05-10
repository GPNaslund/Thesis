enum HealthConnectHealthMetric  {
  heartRate(value: "android.permission.health.READ_HEART_RATE"),
  skinTemperature(value: "android.permission.health.READ_SKIN_TEMPERATURE");

  const HealthConnectHealthMetric({required this.value});

  final String value;

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
