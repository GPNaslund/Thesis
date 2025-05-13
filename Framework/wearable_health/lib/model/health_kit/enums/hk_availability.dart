/// Represents the availability status of Apple HealthKit.
///
/// Possible values:
/// - [available]: HealthKit is available and ready to use
/// - [unavailable]: HealthKit is not available on this device
/// - [needsUpdate]: HealthKit is available but requires an update
enum HealthKitAvailability {
  /// HealthKit is available and ready to use
  available,

  /// HealthKit is not available on this device
  unavailable,

  /// HealthKit is available but requires an update
  needsUpdate;

  /// Creates a [HealthKitAvailability] from a string representation.
  ///
  /// Throws [UnimplementedError] if the input doesn't match any status.
  /// Note: The implementation only handles "available" and "unavailable",
  /// with no explicit case for "needsUpdate".
  factory HealthKitAvailability.fromString(String input) {
    switch (input) {
      case "available":
        return HealthKitAvailability.available;
      case "unavailable":
        return HealthKitAvailability.unavailable;
      default:
        throw UnimplementedError(
          "[HealthKitAvailability] received undefined value: $input",
        );
    }
  }
}
