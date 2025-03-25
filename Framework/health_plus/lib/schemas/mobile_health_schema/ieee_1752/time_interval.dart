import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/duration_unit_value.dart';

class TimeInterval {
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final DurationUnitValue? duration;

  TimeInterval._({this.startDateTime, this.endDateTime, this.duration});

  TimeInterval.startAndDuration(DateTime start, DurationUnitValue dur)
    : startDateTime = start,
      endDateTime = null,
      duration = dur;

  TimeInterval.endAndDuration(DateTime end, DurationUnitValue dur)
    : startDateTime = null,
      endDateTime = end,
      duration = dur;

  TimeInterval.startAndEnd(DateTime start, DateTime end)
    : startDateTime = start,
      endDateTime = end,
      duration = null;

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
