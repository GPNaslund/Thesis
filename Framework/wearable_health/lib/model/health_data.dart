/// Container for multiple types of health data.
///
/// Stores health information in a nested map structure where outer keys
/// represent health metric types and values are lists of individual measurements.
class HealthData {
  /// The structured health data.
  ///
  /// Format:
  /// - Key: String identifier for the health metric type
  /// - Value: List of maps where each map represents a single health measurement
  ///   with its associated properties
  final Map<String, List<Map<String, dynamic>>> data;

  /// Creates a new health data container with the specified data structure.
  HealthData(this.data);
}
