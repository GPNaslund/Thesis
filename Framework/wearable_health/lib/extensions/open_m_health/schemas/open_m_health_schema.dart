/// Base abstract class for all OpenMHealth schema representations.
///
/// OpenMHealth is an open standard for mobile health data interoperability.
/// Classes extending this abstract class must implement [toJson] to provide
/// their specific schema serialization and [schemaId] to identify the schema version.
abstract class OpenMHealthSchema {
  /// Converts this schema object to its JSON representation.
  ///
  /// Implementations should return a map containing the required fields
  /// according to the OpenMHealth standard for the specific schema type.
  ///
  /// @return A map containing the JSON representation of this schema.
  Map<String, dynamic> toJson();

  /// Gets the unique identifier for this OpenMHealth schema.
  ///
  /// The schema ID typically follows the format "omh:schema-name:version.number"
  /// (e.g., "omh:heart-rate:2.0" or "omh:body-temperature:4.0").
  ///
  /// @return The schema identifier string.
  String get schemaId;
}
