import 'package:wearable_health/source/healthKit/health_kit.dart';

import 'source/healthConnect/health_connect.dart';
import 'wearable_health_platform_interface.dart';

class WearableHealth {
  Future<String?> getPlatformVersion() {
    return WearableHealthPlatform.instance.getPlatformVersion();
  }

  static HealthKit getAppleHealthKit() {
    return HealthKit();
  }

  static HealthConnect getGoogleHealthConnect() {
    return HealthConnect();
  }
}
