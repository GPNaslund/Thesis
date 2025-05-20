import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import '../metric_validator.dart';

class HeartRateValidator extends MetricValidator<OpenMHealthHeartRate> {
  final DateTimeRange? expectedRange;
  final Set<String> _timestampsSeen = {};

  HeartRateValidator({this.expectedRange});

  @override
  List<ValidationResult> validateAll(List<OpenMHealthHeartRate> entries) {
    _timestampsSeen.clear();
    return entries.map(validate).toList();
  }

  @override
  ValidationResult validate(OpenMHealthHeartRate entry) {
    final problems = <String>[]; // used for flagging failing fields
    final messages = <String>[]; // human-readable error messages

    // === Validating keys ===
    final keyChecks = <String, dynamic>{};
    final hasValue = entry.heartRate?.value != null;
    final hasUnit = entry.heartRate?.unit != null;
    final hasTimeFrame = entry.effectiveTimeFrame != null;
    final hasInterval = entry.effectiveTimeFrame.timeInterval != null;
    final hasStart = entry.effectiveTimeFrame.timeInterval?.startDateTime != null;
    final hasEnd = entry.effectiveTimeFrame.timeInterval?.endDateTime != null;

    keyChecks['heart_rate exists'] = entry.heartRate != null;
    keyChecks['value exists'] = hasValue;
    keyChecks['unit exists'] = hasUnit;
    keyChecks['time_frame exists'] = hasTimeFrame;
    keyChecks['time_interval exists'] = hasInterval;
    keyChecks['start_date_time exists'] = hasStart;
    keyChecks['end_date_time exists'] = hasEnd;

    if (!hasValue) problems.add('value');
    if (!hasUnit) problems.add('unit');
    if (!hasStart) problems.add('start_date_time');
    if (!hasEnd) problems.add('end_date_time');

    // === Validating values ===
    final valueChecks = <String, dynamic>{};
    final value = entry.heartRate?.value;
    final unit = entry.heartRate?.unit;
    final start = entry.effectiveTimeFrame.timeInterval?.startDateTime;
    final end = entry.effectiveTimeFrame.timeInterval?.endDateTime;

    valueChecks['value'] = value;
    valueChecks['unit'] = unit;
    valueChecks['start_date_time'] = start?.toIso8601String();
    valueChecks['end_date_time'] = end?.toIso8601String();

    if (value != null && (value < 20 || value > 220)) {
      problems.add('value');
      messages.add('Unusual heart rate value: $value');
    }

    if (unit != null && unit != 'beats/min') {
      problems.add('unit');
      messages.add('Unexpected unit: $unit');
    }

    // === Validating record ===
    final recordChecks = <String, dynamic>{};

    if (start != null) {
      final iso = start.toIso8601String();
      final isDuplicate = _timestampsSeen.contains(iso);
      recordChecks['Record is not a duplicate'] = !isDuplicate;

      if (isDuplicate) {
        problems.add('Record is not a duplicate');
        messages.add('Duplicate timestamp: $iso');
      } else {
        _timestampsSeen.add(iso);
      }
    }

    bool inRangeStart = true;
    bool inRangeEnd = true;

    if (expectedRange != null) {
      if (start != null) {
        inRangeStart = !start.isBefore(expectedRange!.start) && !start.isAfter(expectedRange!.end);
        if (!inRangeStart) {
          problems.add('start_date_time');
        }
      }

      if (end != null) {
        inRangeEnd = !end.isBefore(expectedRange!.start) && !end.isAfter(expectedRange!.end);
        if (!inRangeEnd) {
          problems.add('end_date_time');
        }
      }
    }

    final isRecordInRange = inRangeStart && inRangeEnd;
    recordChecks['Record is in range'] = isRecordInRange;

    if (!isRecordInRange) {
      problems.add('Record is in range');
      messages.add('Timestamp outside expected range:\n'
          'expected range:\n'
          'fetch start time: ${expectedRange!.start.toIso8601String()}\n'
          'fetch end time: ${expectedRange!.end.toIso8601String()}');
    }

    return ValidationResult(
      isValid: problems.isEmpty,
      summary: problems.isEmpty ? 'Valid heart rate record' : 'Validation issues found',
      details: {
        'Validating keys exists': keyChecks,
        'Validating values': valueChecks,
        'Validating record': recordChecks,
        'problems': problems,
        'messages': messages,
      },
    );
  }
}
