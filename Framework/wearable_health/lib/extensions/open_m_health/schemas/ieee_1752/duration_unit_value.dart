import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';

/// Represents a duration value with its unit as defined by IEEE 1752 mHealth standard.
///
/// Extends [Ieee1752Schema] to provide a standardized representation of time durations
/// with support for multiple time units (seconds, minutes, hours, days).
class DurationUnitValue extends Ieee1752Schema {
  /// The numeric value of the duration.
  final num value;

  /// The unit of measurement for the duration (e.g., "sec", "min", "h", "d").
  final String unit;

  /// Creates a new duration unit value with the specified value and unit.
  DurationUnitValue({required this.value, required this.unit});

  /// Creates a duration unit value in seconds.
  ///
  /// @param seconds The number of seconds.
  factory DurationUnitValue.seconds(num seconds) =>
      DurationUnitValue(value: seconds, unit: "sec");

  /// Creates a duration unit value in minutes.
  ///
  /// @param minutes The number of minutes.
  factory DurationUnitValue.minutes(num minutes) =>
      DurationUnitValue(value: minutes, unit: "min");

  /// Creates a duration unit value in hours.
  ///
  /// @param hours The number of hours.
  factory DurationUnitValue.hours(num hours) =>
      DurationUnitValue(value: hours, unit: "h");

  /// Creates a duration unit value in days.
  ///
  /// @param days The number of days.
  factory DurationUnitValue.days(num days) =>
      DurationUnitValue(value: days, unit: "d");

  /// Converts this duration unit value to its JSON representation.
  ///
  /// Returns a map with keys "value" and "unit".
  @override
  Map<String, dynamic> toJson() {
    return {"value": value, "unit": unit};
  }
}
