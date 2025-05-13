/// Represents a measured health quantity in HealthKit.
///
/// Stores a numeric value with its associated unit of measurement.
class HKQuantity {
  /// The numeric value of the health measurement.
  final double doubleValue;

  /// The unit of measurement as a string (e.g., "bpm", "degC").
  final String unit;

  /// Creates a new quantity with the specified value and unit.
  ///
  /// Note: The constructor has an unused 'value' parameter that appears
  /// to be redundant with 'doubleValue'.
  const HKQuantity(
    double value, {
    required this.doubleValue,
    required this.unit,
  });

  /// Compares this quantity with another for equality.
  ///
  /// Two [HKQuantity] objects are considered equal if they have
  /// the same value and unit.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HKQuantity &&
          runtimeType == other.runtimeType &&
          doubleValue == other.doubleValue &&
          unit == other.unit;

  /// Generates a hash code based on the value and unit.
  ///
  /// Ensures objects with the same value and unit have the same hash code.
  @override
  int get hashCode => doubleValue.hashCode ^ unit.hashCode;

  /// Returns a string representation of this quantity.
  ///
  /// Format: 'HKQuantity(value unit)'
  @override
  String toString() {
    return 'HKQuantity($doubleValue $unit)';
  }
}
