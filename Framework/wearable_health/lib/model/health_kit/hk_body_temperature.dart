import 'enums/hk_health_metric.dart';
import 'health_kit_data.dart';
import 'hk_entities/hk_quantity_sample.dart';

/// Represents body temperature data from HealthKit.
///
/// Wraps an [HKQuantitySample] containing the temperature measurement
/// and extends [HealthKitData] to provide a standardized interface.
class HKBodyTemperature extends HealthKitData {
  /// The underlying quantity sample containing the temperature measurement.
  ///
  /// Contains the temperature value, timestamps, and metadata.
  late HKQuantitySample data;

  /// Creates a new body temperature record with the specified sample data.
  HKBodyTemperature(this.data);

  /// The health metric type for this data.
  ///
  /// Always returns [HealthKitHealthMetric.bodyTemperature].
  @override
  HealthKitHealthMetric get healthMetric =>
      HealthKitHealthMetric.bodyTemperature;
}
