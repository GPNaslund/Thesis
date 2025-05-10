import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_interval.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/source/healthKit/data/dto/hk_heart_rate.dart';

import '../schemas/ieee_1752/time_frame.dart';

extension OpenMHealthHeartRateConverter on HKHeartRate {
  List<OpenMHealthHeartRate> toOpenMHealthHeartRate() {
    List<OpenMHealthHeartRate> result = [];
    var unitValue = UnitValue(
      value: data.quantity.doubleValue,
      unit: "beatsPerMinute",
    );

    var timeInterval = TimeInterval(
      startTime: data.startDate,
      endTime: data.endDate,
    );

    var timeFrame = TimeFrame(timeInterval: timeInterval);

    result.add(
      OpenMHealthHeartRate(heartRate: unitValue, effectiveTimeFrame: timeFrame)
    );
    return result;
  }
}