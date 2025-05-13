/// Represents a type of health data in HealthKit.
///
/// Used to identify specific categories of health information
/// through a unique string identifier.
class HKObjectType {
  /// The unique string identifier for this health data type.
  ///
  /// Corresponds to HealthKit type identifiers (e.g., "HKQuantityTypeIdentifierHeartRate").
  late String identifier;

  /// Creates a new health data type with the specified identifier.
  HKObjectType(this.identifier);

  /// Compares this object with another for equality.
  ///
  /// Two [HKObjectType] objects are considered equal if they have the same identifier.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HKObjectType &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;

  /// Generates a hash code based on the identifier.
  ///
  /// Ensures objects with the same identifier have the same hash code.
  @override
  int get hashCode => identifier.hashCode;

  /// Returns a string representation of this object.
  ///
  /// Format: 'HKObjectType(identifier)'
  @override
  String toString() {
    return 'HKObjectType($identifier)';
  }
}
