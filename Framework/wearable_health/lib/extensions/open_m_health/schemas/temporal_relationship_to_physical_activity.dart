enum TemporalRelationshipToPhysicalActivity {
  atRest("at rest"),
  active("active"),
  beforeExercise("before exercise"),
  afterExercise("after exercise"),
  duringExercise("during exercise");

  final String value;

  const TemporalRelationshipToPhysicalActivity(this.value);

  Map<String, dynamic> toJson() {
    return { "temporal-relationship-to-physical-activity": value };
  }
}