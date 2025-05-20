import '../../../model/health_connect/hc_entities/heart_rate.dart';
import '../schemas/heart_rate.dart';
import '../schemas/ieee_1752/time_frame.dart';
import '../schemas/ieee_1752/time_interval.dart';
import '../schemas/ieee_1752/unit_value.dart';

/// Extension to convert [HealthConnectHeartRate] data to OpenMHealth heart rate schema format.
extension OpenMHealthHeartRateConverter on HealthConnectHeartRate {
  /// Converts this [HealthConnectHeartRate] instance to a list of [OpenMHealthHeartRate] objects.
  ///
  /// Returns a list of [OpenMHealthHeartRate] objects, one for each heart rate
  /// sample in the source data.
  List<OpenMHealthHeartRate> toOpenMHealthHeartRate() {
    List<OpenMHealthHeartRate> result = [];
    for (final element in samples) {
      UnitValue unitValue = UnitValue(
        value: element.beatsPerMinute,
        unit: "beats/min",
      );

      TimeInterval timeInterval = TimeInterval(
        startTime: element.time,
        endTime: element.time,
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
