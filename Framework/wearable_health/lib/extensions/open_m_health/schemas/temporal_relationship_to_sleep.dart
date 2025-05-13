/// Represents the relationship of a health measurement to sleep as defined by OpenMHealth.
///
/// These values provide context about when a health measurement was taken relative
/// to a person's sleep cycle, which can be clinically relevant for interpretation.
enum TemporalRelationshipToSleep {
  /// Indicates the measurement was taken before the person went to sleep.
  beforeSleeping("before sleeping"),

  /// Indicates the measurement was taken while the person was sleeping.
  duringSleep("during sleep"),

  /// Indicates the measurement was taken when the person woke up.
  onWaking("on waking");

  /// The string representation used in JSON serialization.
  final String jsonValue;

  /// Creates a new temporal relationship with the specified JSON value.
  const TemporalRelationshipToSleep(this.jsonValue);

  /// Converts this temporal relationship to its JSON representation.
  ///
  /// Returns the string value representing this relationship.
  String toJson() => jsonValue;

  /// Creates a temporal relationship from its JSON string representation.
  ///
  /// @param jsonValue The string representation of the temporal relationship.
  /// @return The corresponding [TemporalRelationshipToSleep] value.
  /// @throws ArgumentError if the string does not match any valid relationship.
  static TemporalRelationshipToSleep fromJson(String jsonValue) {
    return TemporalRelationshipToSleep.values.firstWhere(
      (element) => element.jsonValue == jsonValue,
      orElse:
          () =>
              throw ArgumentError(
                'Invalid temporal relationship to sleep value: $jsonValue',
              ),
    );
  }
}
