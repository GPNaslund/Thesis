import 'package:wearable_health/source/healthKit/health_kit.dart';

import 'source/healthConnect/health_connect.dart';
import 'source/health_data_source.dart';
import 'wearable_health_platform_interface.dart';

class WearableHealth {
  Future<String?> getPlatformVersion() {
    return WearableHealthPlatform.instance.getPlatformVersion();
  }

  static HealthDataSource getAppleHealthKit() {
    return HealthKit();
  }

  static HealthDataSource getGoogleHealthConnect() {
    return HealthConnect();
  }
}
