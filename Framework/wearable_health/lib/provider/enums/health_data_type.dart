import 'dart:io';

import 'package:wearable_health/provider/enums/supported_platform.dart';

enum HealthDataType {
  heartRate(value: "heartRate", supportedPlatforms: [SupportedPlatform.android, SupportedPlatform.ios ]),
  skinTemperature(value: "skinTemperature", supportedPlatforms: [SupportedPlatform.android]),
  bodyTemperature(value: "bodyTemperature", supportedPlatforms: [SupportedPlatform.ios]),
  unknown(value: "unknown", supportedPlatforms: []);

  const HealthDataType({ required this.value, required this.supportedPlatforms });

  final String value;
  final List<SupportedPlatform> supportedPlatforms;

  factory HealthDataType.fromString(String input) {
    switch (input) {
      case "heartRate":
        return HealthDataType.heartRate;
      case "skinTemperature":
        return HealthDataType.skinTemperature;
      case "bodyTemperature":
        return HealthDataType.bodyTemperature;
      default:
        return HealthDataType.unknown;
    }
  }
}