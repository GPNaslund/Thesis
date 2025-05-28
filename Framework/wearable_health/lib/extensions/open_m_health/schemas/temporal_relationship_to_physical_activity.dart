/// Enum representing the temporal relationship of a measurement
/// (e.g., heart rate variability) to physical activity.
///
/// This helps provide context on whether the measurement was taken
/// before, during, after, or in the absence of physical exercise.
enum TemporalRelationshipToPhysicalActivity {
/// The measurement was taken when the individual was at rest,
/// not engaged in any significant physical activity.
atRest("at rest"),

/// The measurement was taken while the individual was actively
/// engaged in some form of physical activity or exercise.
active("active"),

/// The measurement was taken immediately or shortly before
/// starting a session of physical exercise.
beforeExercise("before exercise"),

/// The measurement was taken immediately or shortly after
/// concluding a session of physical exercise.
afterExercise("after exercise"),

/// The measurement was taken during an ongoing session
/// of physical exercise.
duringExercise("during exercise");

/// The string representation of the temporal relationship.
final String value;

/// Constructs a [TemporalRelationshipToPhysicalActivity] enum value.
///
/// [value] is the string representation of the temporal relationship.
const TemporalRelationshipToPhysicalActivity(this.value);

/// Converts the enum to a JSON object suitable for serialization.
///
/// Returns a map with the key "temporal-relationship-to-physical-activity"
/// and the relationship's string value.
Map<String, dynamic> toJson() {
return { "temporal-relationship-to-physical-activity": value };
}
}