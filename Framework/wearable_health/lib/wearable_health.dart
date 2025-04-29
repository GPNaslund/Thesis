import 'package:wearable_health/provider/native/health_connect/data/health_connect_data_type.dart';
import 'package:wearable_health/provider/native/health_kit/apple_health_kit.dart';
import 'package:wearable_health/provider/native/health_connect/google_health_connect.dart';
import 'package:wearable_health/provider/native/health_kit/data/health_kit_data_type.dart';
import 'package:wearable_health/provider/provider.dart';

import 'wearable_health_platform_interface.dart';

class WearableHealth {
  Future<String?> getPlatformVersion() {
    return WearableHealthPlatform.instance.getPlatformVersion();
  }

  static Provider getAppleHealthKit(List<HealthKitDataType> dataTypes) {
    return AppleHealthKit(dataTypes);
  }

  static Provider getGoogleHealthConnect(
    List<HealthConnectDataType> dataTypes,
  ) {
    return GoogleHealthConnect(dataTypes);
  }
}
