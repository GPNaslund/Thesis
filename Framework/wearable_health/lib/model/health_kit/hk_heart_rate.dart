import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

/// Represents heart rate data from HealthKit.
///
/// Wraps an [HKQuantitySample] containing the heart rate measurement
/// and extends [HealthKitData] to provide a standardized interface.
class HKHeartRate extends HealthKitData {
  /// The underlying quantity sample containing the heart rate measurement.
  ///
  /// Contains the heart rate value (typically in BPM), timestamps, and metadata.
  late HKQuantitySample data;

  /// Creates a new heart rate record with the specified sample data.
  HKHeartRate(this.data);

  /// The health metric type for this data.
  ///
  /// Always returns [HealthKitHealthMetric.heartRate].
  @override
  HealthKitHealthMetric get healthMetric => HealthKitHealthMetric.heartRate;

  Map<String, dynamic> toJson() {
    return {
      "quantitySample": data.toJson(),
      "healthMetric": HealthKitHealthMetric.heartRate.definition,
    };
  }
}
