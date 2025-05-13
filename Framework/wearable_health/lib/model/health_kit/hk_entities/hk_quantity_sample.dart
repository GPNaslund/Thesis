import 'hk_device.dart';
import 'hk_quantity.dart';
import 'hk_sample.dart';

/// Represents a sample of quantitative health data in HealthKit.
///
/// Contains a measured quantity with an optional count and inherits
/// common sample attributes from [HKSample].
class HKQuantitySample extends HKSample {
  /// The measured health quantity value with its unit.
  late HKQuantity quantity;

  /// Optional count of measurements combined in this sample.
  ///
  /// May represent number of readings, occurrences, or data points.
  late int? count;

  /// Creates a new quantity sample with the specified parameters.
  ///
  /// Requires core sample data plus a quantity measurement. The count
  /// parameter is required but can be null.
  HKQuantitySample({
    required super.uuid,
    required super.startDate,
    required super.endDate,
    super.metadata,
    HKDevice? super.device,
    super.sourceRevision,
    required this.quantity,
    required super.sampleType,
    required this.count,
  });

  /// Returns a string representation of this quantity sample.
  ///
  /// Format: 'HKQuantitySample(uuid: uuid, quantity: quantity, startDate: startDate)'
  @override
  String toString() {
    return 'HKQuantitySample(uuid: $uuid, quantity: $quantity, startDate: $startDate)';
  }
}
