import '../../../model/health_connect/hc_entities/heart_rate.dart';
import '../schemas/heart_rate.dart';
import '../schemas/ieee_1752/time_frame.dart';
import '../schemas/ieee_1752/time_interval.dart';
import '../schemas/ieee_1752/unit_value.dart';

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