enum MethodType {
  getPlatformVersion(value: "getPlatformVersion"),
  checkPermissions(value: "checkPermissions"),
  requestPermissions(value: "requestPermissions"),
  dataStoreAvailability(value: "dataStoreAvailability"),
  getData(value: "getData");

  const MethodType({required this.value});

  final String value;
}