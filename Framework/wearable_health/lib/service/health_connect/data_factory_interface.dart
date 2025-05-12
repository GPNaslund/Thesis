import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';

abstract class HCDataFactory {
  HealthConnectHeartRate createHeartRate(Map<String, dynamic> data);
  HealthConnectSkinTemperature createSkinTemperature(Map<String, dynamic> data);
}
