/// Base abstract class for all IEEE 1752 mHealth schema representations.
///
/// IEEE 1752 is a standard for mobile health data interoperability.
/// Classes extending this abstract class must implement [toJson] to provide
/// their specific schema serialization according to the standard.
abstract class Ieee1752Schema {
  /// Converts this schema object to its JSON representation.
  ///
  /// Implementations should return a map containing the required fields
  /// according to the IEEE 1752 standard for the specific schema type.
  ///
  /// @return A map containing the JSON representation of this schema.
  Map<String, dynamic> toJson();
}
