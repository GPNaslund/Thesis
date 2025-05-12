enum HealthConnectAvailability {
  available,
  unavailable,
  needsUpdate;

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
