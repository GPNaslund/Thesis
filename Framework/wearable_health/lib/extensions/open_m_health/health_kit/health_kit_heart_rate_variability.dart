import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_algorithm.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate_variability.dart';

extension OpenMHealthHeartRateVariabilityConverter on HkHeartRateVariability {
  List<OpenMHealthHeartRateVariability> toOpenMHealthHeartRateVariability() {
    List<OpenMHealthHeartRateVariability> result = [];
    var unit = UnitValue(value: data.quantity.value, unit: data.quantity.unit);
    var timeFrame = TimeFrame(dateTime: data.startDate);

    var dataPoint = OpenMHealthHeartRateVariability(
      heartRateVariability: unit, 
      algorithm: HrvAlgorithm.sdnn, 
      effectiveTimeFrame: timeFrame
      );
      result.add(dataPoint);
      return result;
  }
}