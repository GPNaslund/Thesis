import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_algorithm.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_variability_rmssd.dart';

extension OpenMHealthHeartRateVariabilityConverter on HealthConnectHeartRateVariabilityRmssd {
  List<OpenMHealthHeartRateVariability> toOpenMHealthHeartRateVariabilityRmssd() {
    var algorithm = HrvAlgorithm.rmssd;
    var unitValue = UnitValue(value: heartRateVariabilityMillis, unit: "hrv/ms");
    var timeframe = TimeFrame(dateTime: time);
    var hrv = OpenMHealthHeartRateVariability(
      heartRateVariability: unitValue,
      algorithm: algorithm,
      effectiveTimeFrame: timeframe
    );
    return [hrv];
  }
}