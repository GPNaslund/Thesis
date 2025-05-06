import 'source/healthConnect/health_connect.dart';
import 'source/health_data_source.dart';
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
