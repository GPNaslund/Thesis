import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_interval.dart';

/// Represents a time frame as defined by IEEE 1752 mHealth standard.
///
/// Extends [Ieee1752Schema] to provide a standardized representation of time references
/// that can be either a specific point in time (date-time) or a time interval with
/// start and end times.
class TimeFrame extends Ieee1752Schema {
  /// A specific point in time. Will be null if [timeInterval] is used.
  final DateTime? dateTime;

  /// A time interval with start and end times. Will be null if [dateTime] is used.
  final TimeInterval? timeInterval;

  /// Creates a time frame representing a specific point in time.
  ///
  /// @param time The specific date and time.
  TimeFrame.dateTime(DateTime time) : dateTime = time, timeInterval = null;

  /// Creates a time frame representing a time interval.
  ///
  /// @param interval The time interval with start and end times.
  TimeFrame.timeInterval(TimeInterval interval)
    : dateTime = null,
      timeInterval = interval;

  /// Creates a time frame with either a date-time or a time interval.
  ///
  /// Exactly one of [dateTime] or [timeInterval] must be provided.
  ///
  /// @param dateTime Optional specific point in time.
  /// @param timeInterval Optional time interval with start and end times.
  /// @throws ArgumentError if both parameters are null or both are non-null.
  factory TimeFrame({DateTime? dateTime, TimeInterval? timeInterval}) {
    if (dateTime != null && timeInterval == null) {
      return TimeFrame.dateTime(dateTime);
    } else if (dateTime == null && timeInterval != null) {
      return TimeFrame.timeInterval(timeInterval);
    } else {
      throw ArgumentError("Both dateTime and timeInterval cannot be null");
    }
  }

  /// Converts this time frame to its JSON representation.
  ///
  /// Returns a map with either 'date_time' (ISO 8601 string) or 'time_interval' (object).
  @override
  Map<String, dynamic> toJson() {
    if (dateTime != null) {
      return {'date_time': dateTime!.toIso8601String()};
    } else {
      return {'time_interval': timeInterval!.toJson()};
    }
  }
}
