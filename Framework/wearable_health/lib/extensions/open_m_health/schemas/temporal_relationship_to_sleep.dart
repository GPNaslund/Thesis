enum TemporalRelationshipToSleep {
  beforeSleeping("before sleeping"),
  duringSleep("during sleep"),
  onWaking("on waking");

  final String jsonValue;

  const TemporalRelationshipToSleep(this.jsonValue);

  String toJson() => jsonValue;

  static TemporalRelationshipToSleep fromJson(String jsonValue) {
    return TemporalRelationshipToSleep.values.firstWhere(
            (element) => element.jsonValue == jsonValue,
        orElse: () => throw ArgumentError(
            'Invalid temporal relationship to sleep value: $jsonValue'));
  }
}