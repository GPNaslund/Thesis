// lib/services/metric_validators/open_m_health/heart_rate.dart

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
    final problems = <String>[];
    final messages = <String>[];

    // === Validating keys ===
    final keyChecks = <String, dynamic>{};
    final hasValue = entry.heartRate?.value != null;
    final hasUnit = entry.heartRate?.unit != null;
    final hasTimeFrame = entry.effectiveTimeFrame != null;
    final hasDateTime = entry.effectiveTimeFrame.dateTime != null;

    keyChecks['heart_rate exists'] = entry.heartRate != null;
    keyChecks['value exists'] = hasValue;
    keyChecks['unit exists'] = hasUnit;
    keyChecks['time_frame exists'] = hasTimeFrame;
    keyChecks['date_time exists'] = hasDateTime;

    if (!hasValue) problems.add('value');
    if (!hasUnit) problems.add('unit');
    if (!hasDateTime) problems.add('date_time');

    // === Validating values ===
    final valueChecks = <String, dynamic>{};
    final value = entry.heartRate?.value;
    final unit = entry.heartRate?.unit;
    final dateTime = entry.effectiveTimeFrame.dateTime;

    valueChecks['value'] = value;
    valueChecks['unit'] = unit;
    valueChecks['date_time'] = dateTime?.toIso8601String();

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

    if (dateTime != null) {
      final iso = dateTime.toIso8601String();
      final isDuplicate = _timestampsSeen.contains(iso);
      recordChecks['Record is not a duplicate'] = !isDuplicate;

      if (isDuplicate) {
        problems.add('Record is not a duplicate');
        messages.add('Duplicate timestamp: $iso');
      } else {
        _timestampsSeen.add(iso);
      }
    }

    bool inRange = true;

    if (expectedRange != null && dateTime != null) {
      inRange = !dateTime.isBefore(expectedRange!.start) &&
          !dateTime.isAfter(expectedRange!.end);

      recordChecks['Record is in range'] = inRange;

      if (!inRange) {
        problems.add('Record is in range');
        messages.add('Timestamp outside expected range:\n'
            'expected range:\n'
            'start: ${expectedRange!.start.toIso8601String()}\n'
            'end: ${expectedRange!.end.toIso8601String()}');
      }
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
