/// Represents health metrics available through Apple HealthKit.
///
/// Each metric corresponds to a specific HealthKit identifier for accessing
/// different types of health data.
enum HealthKitHealthMetric {
  /// Heart rate measurement data.
  /// HealthKit identifier: HKQuantityTypeIdentifierHeartRate
  heartRate(value: "HKQuantityTypeIdentifierHeartRate"),

  /// Body temperature measurement data.
  /// HealthKit identifier: HKQuantityTypeIdentifierBodyTemperature
  bodyTemperature(value: "HKQuantityTypeIdentifierBodyTemperature"),

  /// Heart rate variability measurement data.
  /// HealthKit identifier: HKQuantityTypeIdentifierHeartRateVariabilitySDNN
  heartRateVariability(
    value: "HKQuantityTypeIdentifierHeartRateVariabilitySDNN",
  );

  /// Creates a new [HealthKitHealthMetric] with the associated HealthKit identifier.
  const HealthKitHealthMetric({required this.value});

  /// The HealthKit identifier string for this metric.
  final String value;

  /// Returns the HealthKit identifier string for this metric.
  String get definition => value;

  /// Creates a [HealthKitHealthMetric] from a HealthKit identifier string.
  ///
  /// Throws [UnimplementedError] if the input doesn't match any known identifier.
  factory HealthKitHealthMetric.fromString(String input) {
    for (final metric in HealthKitHealthMetric.values) {
      if (metric.value == input) {
        return metric;
      }
    }
    throw UnimplementedError(
      "[HealthKitHealthMetric] Received unknown metric string: $input",
    );
  }
}
