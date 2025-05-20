import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_interval.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';

import '../schemas/ieee_1752/time_frame.dart';

/// Extension to convert [HKHeartRate] data to OpenMHealth heart rate schema format.
extension OpenMHealthHeartRateConverter on HKHeartRate {
  /// Converts this [HKHeartRate] instance to a list of [OpenMHealthHeartRate] objects.
  ///
  /// Returns a list containing a single [OpenMHealthHeartRate] object.
  /// The list format allows for consistency with other converters that may
  /// return multiple schema objects.
  List<OpenMHealthHeartRate> toOpenMHealthHeartRate() {
    List<OpenMHealthHeartRate> result = [];
    var unitValue = UnitValue(
      value: data.quantity.doubleValue,
      unit: "beatsPerMinute",
    );

    var timeFrame = TimeFrame(dateTime: data.startDate);

    result.add(
      OpenMHealthHeartRate(heartRate: unitValue, effectiveTimeFrame: timeFrame),
    );
    return result;
  }
}
