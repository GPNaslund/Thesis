import 'hk_sample_type.dart';

/// Defines how quantity samples should be aggregated in HealthKit.
///
/// - [cumulative]: Values add up over time (e.g., steps, calories)
/// - [discrete]: Values represent instantaneous measurements (e.g., heart rate, temperature)
enum HKQuantityAggregationStyle {
  /// Values that accumulate or add up over time.
  ///
  /// Examples: step count, calories burned, distance walked.
  cumulative,

  /// Values that represent point-in-time measurements.
  ///
  /// Examples: heart rate, blood pressure, body temperature.
  discrete,
}

/// Represents a type of quantitative health data in HealthKit.
///
/// Extends [HKSampleType] with information about how samples
/// of this type should be aggregated.
class HKQuantityType extends HKSampleType {
  /// Determines how multiple samples of this type should be combined.
  final HKQuantityAggregationStyle aggregationStyle;

  /// Creates a new quantity type with the specified identifier and aggregation style.
  HKQuantityType({required super.identifier, required this.aggregationStyle});

  /// Creates a predefined heart rate quantity type.
  ///
  /// Uses discrete aggregation style and the standard HealthKit identifier.
  HKQuantityType.heartRate()
    : aggregationStyle = HKQuantityAggregationStyle.discrete,
      super(identifier: 'HKQuantityTypeIdentifierHeartRate');

  /// Creates a predefined body temperature quantity type.
  ///
  /// Uses discrete aggregation style and the standard HealthKit identifier.
  HKQuantityType.bodyTemperature()
    : aggregationStyle = HKQuantityAggregationStyle.discrete,
      super(identifier: 'HKQuantityTypeIdentifierBodyTemperature');

  /// Compares this quantity type with another for equality.
  ///
  /// Two [HKQuantityType] objects are considered equal if they have
  /// the same identifier and aggregation style.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is HKQuantityType &&
          runtimeType == other.runtimeType &&
          aggregationStyle == other.aggregationStyle;

  /// Generates a hash code based on the superclass hash and aggregation style.
  @override
  int get hashCode => super.hashCode ^ aggregationStyle.hashCode;

  /// Returns a string representation of this quantity type.
  ///
  /// Format: 'HKQuantityType(identifier, aggregationStyle)'
  @override
  String toString() {
    return 'HKQuantityType($identifier, $aggregationStyle)';
  }
}
