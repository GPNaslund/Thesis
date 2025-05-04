import 'package:wearable_health/provider/native/health_kit/apple_health_kit.dart';
import 'package:wearable_health/provider/native/health_connect/google_health_connect.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/source/healthConnect/health_connect.dart';
import 'package:wearable_health/source/health_data_source.dart';

import 'wearable_health_platform_interface.dart';

class WearableHealth {
  Future<String?> getPlatformVersion() {
    return WearableHealthPlatform.instance.getPlatformVersion();
  }

  /*
  static HealthDataSource getAppleHealthKit() {
    return AppleHealthKit();
  }
  */

  static HealthDataSource getGoogleHealthConnect() {
    return HealthConnect();
  }
}
