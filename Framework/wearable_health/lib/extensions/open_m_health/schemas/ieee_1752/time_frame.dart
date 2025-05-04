import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_interval.dart';

class TimeFrame extends Ieee1752Schema {
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

  @override
  Map<String, dynamic> toJson() {
    if (dateTime != null) {
      return {'date_time': dateTime!.toIso8601String()};
    } else {
      return {'time_interval': timeInterval!.toJson()};
    }
  }
}
