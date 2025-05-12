enum HealthKitAvailability {
  available,
  unavailable,
  needsUpdate;

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
