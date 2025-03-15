class WearableHealthDataConstants {
  WearableHealthDataConstants._();

  // Channel names
  static const String channelName = "se.lnu.thesis.wearable_health/methods";
  static const String eventChannelName = "se.lnu.thesis.wearable_health/events";

  // Method call names
  static const String methodGetPlatformVersion = "getPlatformVersion";
  static const String methodRequestPermissions = "requestPermissions";
  static const String methodStartCollecting = "startCollecting";
  static const String methodStopCollecting = "stopCollecting";
  static const String methodGetHealthData = "getHealthData";
}
