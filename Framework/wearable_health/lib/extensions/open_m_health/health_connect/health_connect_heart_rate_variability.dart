import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_algorithm.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_variability_rmssd.dart';

/// Extension on [HealthConnectHeartRateVariabilityRmssd] to convert Health Connect
/// heart rate variability data (specifically RMSSD) into the Open mHealth format.
extension OpenMHealthHeartRateVariabilityConverter on HealthConnectHeartRateVariabilityRmssd {
  /// Converts this [HealthConnectHeartRateVariabilityRmssd] object into a list
  /// containing a single [OpenMHealthHeartRateVariability] object.
  ///
  /// The conversion maps the RMSSD value and timestamp from the Health Connect
  /// format to the corresponding fields in the Open mHealth heart rate variability schema.
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