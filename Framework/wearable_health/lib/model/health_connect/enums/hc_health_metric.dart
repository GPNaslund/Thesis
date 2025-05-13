/// Represents health metrics available through Health Connect.
///
/// Each metric corresponds to a specific Android Health Connect permission.
enum HealthConnectHealthMetric {
  /// Heart rate measurement data.
  /// Permission: android.permission.health.READ_HEART_RATE
  heartRate(value: "android.permission.health.READ_HEART_RATE"),

  /// Skin temperature measurement data.
  /// Permission: android.permission.health.READ_SKIN_TEMPERATURE
  skinTemperature(value: "android.permission.health.READ_SKIN_TEMPERATURE");

  /// Creates a new [HealthConnectHealthMetric] with the associated permission value.
  const HealthConnectHealthMetric({required this.value});

  /// The Android Health Connect permission string for this metric.
  final String value;

  /// Returns the permission string for this metric.
  String get definition => value;

  /// Creates a [HealthConnectHealthMetric] from a permission string.
  ///
  /// Throws [UnimplementedError] if the input doesn't match any known permission.
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
