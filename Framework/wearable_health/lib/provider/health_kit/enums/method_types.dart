enum MethodType {
  getPlatformVersion(value: "getPlatformVersion"),
  hasPermission(value: "hasPermission"),
  requestPermission(value: "requestPermission"),
  dataStoreAvailability(value: "dataStoreAvailability");

  const MethodType({required this.value});

  final String value;
}
