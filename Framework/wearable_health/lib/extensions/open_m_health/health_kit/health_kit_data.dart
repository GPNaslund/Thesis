import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';

import '../../../model/health_kit/health_kit_data.dart';

extension OpenMHealthConverter on HealthKitData {
  List<OpenMHealthSchema> toOpenMHealth() {
    if (this is HKHeartRate) {
      return (this as HKHeartRate).toOpenMHealthHeartRate();
    }

    if (this is HKBodyTemperature) {
      return (this as HKBodyTemperature).toOpenMHealthBodyTemperature();
    }

    throw UnimplementedError("Unimplemented HealthKitData type for OpenMHealth conversion");
  }
}