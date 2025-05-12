import 'package:wearable_health/service/factory/factory.dart';
import 'package:wearable_health/service/factory/factory_interface.dart';
import 'package:wearable_health/service/health_connect/health_connect.dart';
import '../service/health_connect/health_connect_interface.dart';
import '../service/health_kit/health_kit.dart';
import '../service/health_kit/health_kit_interface.dart';

class WearableHealth {
  FactoryInterface objFactory = FactoryImpl();

  HealthKit getAppleHealthKit() {
    return HealthKitImpl(
      objFactory.getMethodChannel(),
      objFactory.getHKDataFactory(),
      objFactory.getJsonConverter(),
    );
  }

  HealthConnect getGoogleHealthConnect() {
    return HealthConnectImpl(
      objFactory.getMethodChannel(),
      objFactory.getHCDataFactory(),
      objFactory.getJsonConverter(),
    );
  }
}
