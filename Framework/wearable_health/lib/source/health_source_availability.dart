enum HealthSourceAvailability {
  available,
  unavailable,
  needsUpdate;

  factory HealthSourceAvailability.fromString(String input) {
    switch (input) {
      case "available":
        return HealthSourceAvailability.available;
      case "unavailable":
        return HealthSourceAvailability.unavailable;
      case "needsUpdate":
        return HealthSourceAvailability.needsUpdate;
      default:
        throw UnimplementedError(
          "[HealthSourceAvailability] received undefined value: $input",
        );
    }
  }
}
