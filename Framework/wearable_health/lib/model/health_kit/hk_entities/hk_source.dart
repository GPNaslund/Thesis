/// Represents a source of health data in HealthKit.
///
/// Identifies an app or service that provided health information
/// to HealthKit through its bundle identifier and name.
class HKSource {
  /// The bundle identifier of the source app.
  ///
  /// For iOS apps, this is typically in reverse domain name format (e.g., "com.example.myapp").
  final String bundleIdentifier;

  /// The display name of the source app.
  final String name;

  /// Creates a new source with the specified bundle identifier and name.
  const HKSource({required this.bundleIdentifier, required this.name});
}
