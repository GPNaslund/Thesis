enum DataStoreAvailability {
  available(value: "available"),
  unavailable(value: "unavailable"),
  needsUpdate(value: "needsUpdate"),
  unkown(value: "unkown");

  const DataStoreAvailability({required this.value});

  final String value;

  factory DataStoreAvailability.fromString(String input) {
    switch (input) {
      case "available":
        return DataStoreAvailability.available;
      case "unavailable":
        return DataStoreAvailability.unavailable;
      case "needsUpdate":
        return DataStoreAvailability.needsUpdate;
      default:
        return DataStoreAvailability.unkown;
    }
  }
}
