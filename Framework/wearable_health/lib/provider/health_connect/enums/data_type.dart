enum HealthConnectDataType {
  heartRate(value: "android.permission.health.READ_HEART_RATE"),
  skinTemperature(value: "android.permission.health.READ_SKIN_TEMPERATURE");

  const HealthConnectDataType({required this.value});

  final String value;
}
