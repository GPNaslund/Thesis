
import 'package:wearable_health/provider/apple_health_kit.dart';
import 'package:wearable_health/provider/google_health_connect.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/provider/provider_type.dart';

import 'wearable_health_platform_interface.dart';

class WearableHealth {
  Future<String?> getPlatformVersion() {
    return WearableHealthPlatform.instance.getPlatformVersion();
  }

  static Provider getDataProvider(ProviderType type) {
    switch (type) {
      case ProviderType.appleHealthKit:
        return AppleHealthKit();
      case ProviderType.googleHealthConnect:
        return GoogleHealthConnect();
    }
  }

}
