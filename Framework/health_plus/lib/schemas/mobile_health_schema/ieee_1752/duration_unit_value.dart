class DurationUnitValue {
  final num value;
  final String unit;

  DurationUnitValue({required this.value, required this.unit});

  factory DurationUnitValue.seconds(num seconds) =>
      DurationUnitValue(value: seconds, unit: "sec");
  factory DurationUnitValue.minutes(num minutes) =>
      DurationUnitValue(value: minutes, unit: "min");
  factory DurationUnitValue.hours(num hours) =>
      DurationUnitValue(value: hours, unit: "h");
  factory DurationUnitValue.days(num days) =>
      DurationUnitValue(value: days, unit: "d");

  Map<String, dynamic> toJson() {
    return {"value": value, "unit": unit};
  }
}
