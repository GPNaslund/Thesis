/// Represents the availability status of Health Connect.
///
/// Possible values:
/// - [available]: Health Connect is installed and ready to use
/// - [unavailable]: Health Connect is not installed
/// - [needsUpdate]: Health Connect is installed but requires an update
enum HealthConnectAvailability {
  /// Health Connect is installed and ready to use
  available,

  /// Health Connect is not installed
  unavailable,

  /// Health Connect is installed but requires an update
  needsUpdate;

  /// Creates a [HealthConnectAvailability] from a string representation.
  ///
  /// Throws [UnimplementedError] if the input doesn't match any status.
  factory HealthConnectAvailability.fromString(String input) {
    switch (input) {
      case "available":
        return HealthConnectAvailability.available;
      case "unavailable":
        return HealthConnectAvailability.unavailable;
      case "needsUpdate":
        return HealthConnectAvailability.needsUpdate;
      default:
        throw UnimplementedError(
          "[HealthConnectAvailability] received undefined value: $input",
        );
    }
  }
}
