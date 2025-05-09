
enum HealthKitHealthMetric {
  heartRate(value: "HKQuantityTypeIdentifierHeartRate"),
  bodyTemperature(value: "HKQuantityTypeIdentifierBodyTemperature");

  const HealthKitHealthMetric({ required this.value });

  final String value;

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