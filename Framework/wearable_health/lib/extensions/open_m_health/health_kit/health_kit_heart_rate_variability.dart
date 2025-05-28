import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_algorithm.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate_variability.dart';

/// Extension on [HkHeartRateVariability] (presumably an Apple HealthKit heart rate variability type)
/// to convert its data into the Open mHealth format.
extension OpenMHealthHeartRateVariabilityConverter on HkHeartRateVariability {
  List<OpenMHealthHeartRateVariability> toOpenMHealthHeartRateVariability() {
    /// Converts this [HkHeartRateVariability] object into a list
    /// containing a single [OpenMHealthHeartRateVariability] object.
    ///
    /// The conversion maps the HealthKit HRV value, unit, and start date
    /// to the corresponding fields in the Open mHealth heart rate variability schema.
    /// It assumes the SDNN algorithm for this conversion.
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