import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/time_interval.dart';

class TimeFrame {
  final DateTime? dateTime;
  final TimeInterval? timeInterval;

  TimeFrame.dateTime(DateTime time) : dateTime = time, timeInterval = null;

  TimeFrame.timeInterval(TimeInterval interval)
    : dateTime = null,
      timeInterval = interval;

  factory TimeFrame({DateTime? dateTime, TimeInterval? timeInterval}) {
    if (dateTime != null && timeInterval == null) {
      return TimeFrame.dateTime(dateTime);
    } else if (dateTime == null && timeInterval != null) {
      return TimeFrame.timeInterval(timeInterval);
    } else {
      throw ArgumentError("Both dateTime and timeInterval cannot be null");
    }
  }

  Map<String, dynamic> toJson() {
    if (dateTime != null) {
      return {'date_time': dateTime!.toIso8601String()};
    } else {
      return {'time_interval': timeInterval!.toJson()};
    }
  }
}
