enum MethodType {
  getPlatformVersion(value: "getPlatformVersion"),
  hasPermissions(value: "hasPermissions"),
  requestPermissions(value: "requestPermissions"),
  dataStoreAvailability(value: "dataStoreAvailability");

  const MethodType({required this.value});

  final String value;
}
