import 'package:wearable_health/service/factory/factory.dart';
import 'package:wearable_health/service/factory/factory_interface.dart';
import 'package:wearable_health/service/health_connect/health_connect.dart';
import '../service/health_connect/health_connect_interface.dart';
import '../service/health_kit/health_kit.dart';
import '../service/health_kit/health_kit_interface.dart';

/// API Entry point
///
/// Provides an [HealthKit] instance through [getAppleHealthKit]
/// and [HealthConnect] instance through [getGoogleHealthConnect]
class WearableHealth {
  /// Creates instances of necessary dependencies
  FactoryInterface objFactory = FactoryImpl();

  /// Creates and returns instance of [HealthKit]
  HealthKit getAppleHealthKit() {
    return HealthKitImpl(
      objFactory.getMethodChannel(),
      objFactory.getHKDataFactory(),
      objFactory.getJsonConverter(),
    );
  }

  /// Creates and returns instance of [HealthConnect]
  HealthConnect getGoogleHealthConnect() {
    return HealthConnectImpl(
      objFactory.getMethodChannel(),
      objFactory.getHCDataFactory(),
      objFactory.getJsonConverter(),
    );
  }
}
