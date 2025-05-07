import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_skin_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/source/healthConnect/data/dto/heart_rate.dart';
import 'package:wearable_health/source/healthConnect/data/dto/skin_temperature.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';

extension OpenMHealthConverter on HealthConnectData {
  List<OpenMHealthSchema> toOpenMHealth() {
    if (this is HealthConnectHeartRate) {
      return (this as HealthConnectHeartRate).toOpenMHealthHeartRate();
    }

    if (this is HealthConnectSkinTemperature) {
      return (this as HealthConnectSkinTemperature).toOpenMHealthBodyTemperature();
    }

    throw UnimplementedError("Unimplemented HealthDataType");
  }
}
