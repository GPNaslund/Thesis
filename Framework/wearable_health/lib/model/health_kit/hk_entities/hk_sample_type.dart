import 'hk_object_type.dart';

/// Represents a type of health sample in HealthKit.
///
/// A specialized subclass of [HKObjectType] that specifically
/// identifies types of health data that can be stored as samples.
/// Serves as a base class for more specific sample type classes.
class HKSampleType extends HKObjectType {
  /// Creates a new sample type with the specified identifier.
  ///
  /// The identifier should correspond to a valid HealthKit sample type.
  HKSampleType({required String identifier}) : super(identifier);
}
