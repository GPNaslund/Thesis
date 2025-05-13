import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/duration_unit_value.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';

/// Represents a time interval as defined by IEEE 1752 mHealth standard.
///
/// Extends [Ieee1752Schema] to provide a standardized representation of time intervals
/// using different combinations of start time, end time, and duration.
class TimeInterval extends Ieee1752Schema {
  /// The start date and time of the interval. May be null when using end time and duration.
  final DateTime? startDateTime;

  /// The end date and time of the interval. May be null when using start time and duration.
  final DateTime? endDateTime;

  /// The duration of the interval. May be null when using start and end times.
  final DurationUnitValue? duration;

  /// Creates a time interval with a start time and duration.
  ///
  /// @param start The start date and time.
  /// @param dur The duration of the interval.
  TimeInterval.startAndDuration(DateTime start, DurationUnitValue dur)
    : startDateTime = start,
      endDateTime = null,
      duration = dur;

  /// Creates a time interval with an end time and duration.
  ///
  /// @param end The end date and time.
  /// @param dur The duration of the interval.
  TimeInterval.endAndDuration(DateTime end, DurationUnitValue dur)
    : startDateTime = null,
      endDateTime = end,
      duration = dur;

  /// Creates a time interval with explicit start and end times.
  ///
  /// @param start The start date and time.
  /// @param end The end date and time.
  TimeInterval.startAndEnd(DateTime start, DateTime end)
    : startDateTime = start,
      endDateTime = end,
      duration = null;

  /// Creates a time interval with one of three supported combinations:
  /// - Start time and duration
  /// - End time and duration
  /// - Start time and end time
  ///
  /// @param startTime Optional start date and time.
  /// @param endTime Optional end date and time.
  /// @param duration Optional duration of the interval.
  /// @throws ArgumentError if an invalid combination of parameters is provided.
  factory TimeInterval({
    DateTime? startTime,
    DateTime? endTime,
    DurationUnitValue? duration,
  }) {
    if (startTime != null && duration != null && endTime == null) {
      return TimeInterval.startAndDuration(startTime, duration);
    } else if (startTime == null && duration != null && endTime != null) {
      return TimeInterval.endAndDuration(endTime, duration);
    } else if (startTime != null && duration == null && endTime != null) {
      return TimeInterval.startAndEnd(startTime, endTime);
    } else {
      throw ArgumentError("Invalid combination of parameters for TimeInterval");
    }
  }

  /// Converts this time interval to its JSON representation.
  ///
  /// Returns a map with keys for the available time components:
  /// - "start_date_time" (ISO 8601 string) if start time is present
  /// - "end_date_time" (ISO 8601 string) if end time is present
  /// - "duration" (object) if duration is present
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (startDateTime != null) {
      json["start_date_time"] = startDateTime!.toIso8601String();
    }
    if (endDateTime != null) {
      json["end_date_time"] = endDateTime!.toIso8601String();
    }
    if (duration != null) {
      json["duration"] = duration!.toJson();
    }
    return json;
  }
}
