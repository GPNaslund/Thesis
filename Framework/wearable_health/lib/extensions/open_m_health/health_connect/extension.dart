import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_interval.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/source/healthConnect/data/dto/heart_rate.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';

extension OpenMHealthConverter on HealthConnectData {
  List<OpenMHealthSchema> toOpenMHealth() {
    if (this is HealthConnectHeartRate) {
      return (this as HealthConnectHeartRate).toOpenMHealthHeartRate();
    }

    throw UnimplementedError("Unimplemented HealthDataType");
  }
}

extension OpenMHealthHeartRateConverter on HealthConnectHeartRate {
  List<OpenMHealthHeartRate> toOpenMHealthHeartRate() {
    List<OpenMHealthHeartRate> result = [];
    for (final element in samples) {
      UnitValue unitValue = UnitValue(
        value: element.beatsPerMinute,
        unit: "beatsPerMinute",
      );

      TimeInterval timeInterval = TimeInterval(
        startTime: startTime,
        endTime: endTime,
      );
      TimeFrame timeFrame = TimeFrame(timeInterval: timeInterval);

      result.add(
        OpenMHealthHeartRate(
          heartRate: unitValue,
          effectiveTimeFrame: timeFrame,
        ),
      );
    }
    return result;
  }
}
