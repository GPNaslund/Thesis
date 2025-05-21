import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_type.dart';

/// Represents Heart rate variability from HealthKit.
///
/// Wraps an [HKQuantitySample] containing the heart rate variability measurement
/// and extends [HealthKitData] to provide a standardized interface.
class HkHeartRateVariability extends HealthKitData {
  HKQuantitySample data;

  /// The underlying quantity sample containing the heart rate variability measurement.
  ///
  /// Contains the heart rate variability value, timestamps, and metadata.
  HkHeartRateVariability(this.data);

  /// The health metric type for this data.
  ///
  /// Always returns [HealthKitHealthMetric.heartRateVariability].
  @override
  HealthKitHealthMetric get healthMetric =>
      HealthKitHealthMetric.heartRateVariability;

  Map<String, dynamic> toJson() {
    return {
      "quantitySample": data.toJson(),
      "healthMetric": HealthKitHealthMetric.heartRateVariability.definition,
    };
  }
}
