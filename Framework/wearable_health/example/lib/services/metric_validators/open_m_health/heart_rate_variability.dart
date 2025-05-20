// lib/services/metric_validators/open_m_health/heart_rate_variability.dart

import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';
import '../metric_validator.dart';

class HeartRateVariabilityValidator extends MetricValidator<OpenMHealthHeartRateVariability> {
  final DateTimeRange? expectedRange;
  final Set<String> _timestampsSeen = {};

  HeartRateVariabilityValidator({this.expectedRange});

  @override
  List<ValidationResult> validateAll(List<OpenMHealthHeartRateVariability> entries) {
    _timestampsSeen.clear();
    return entries.map(validate).toList();
  }

  @override
  ValidationResult validate(OpenMHealthHeartRateVariability entry) {
    final problems = <String>[];
    final messages = <String>[];

    final hrv = entry.heartRateVariability;
    final algorithm = entry.algorithm;
    final time = entry.effectiveTimeFrame.dateTime;

    // === Validating keys ===
    final keyChecks = <String, dynamic>{
      'heart_rate_variability exists': hrv != null,
      'value exists': hrv?.value != null,
      'unit exists': hrv?.unit != null,
      'algorithm exists': algorithm != null,
      'effective_time_frame exists': entry.effectiveTimeFrame != null,
      'date_time exists': time != null,
    };

    if (hrv?.value == null) problems.add('value');
    if (hrv?.unit == null) problems.add('unit');
    if (algorithm == null) problems.add('algorithm');
    if (time == null) problems.add('date_time');

    // === Validating values ===
    final valueChecks = <String, dynamic>{
      'value': hrv?.value,
      'unit': hrv?.unit,
      'algorithm': algorithm,
      'date_time': time?.toIso8601String(),
    };

    if (hrv?.value != null) {
      final val = hrv!.value!;
      if (val < 5 || val > 250) {
        problems.add('value');
        messages.add('HRV value is outside of valid values: $val');
      }
    } else {
      messages.add('Missing HRV value.');
    }

    if (hrv?.unit != null && hrv!.unit != 'hrv/ms') {
      problems.add('unit');
      messages.add('HRV unit is not: ${hrv.unit}');
    }

    // === Validating record ===
    final recordChecks = <String, dynamic>{};

    if (time != null) {
      final currentIso = time.toIso8601String();
      final isDuplicate = _timestampsSeen.contains(currentIso);
      recordChecks['Record is not a duplicate'] = !isDuplicate;

      if (isDuplicate) {
        problems.add('Record is not a duplicate');
        messages.add('Duplicate timestamp: $currentIso');
      } else {
        _timestampsSeen.add(currentIso);
      }

      final inRange = expectedRange == null ||
          (!time.isBefore(expectedRange!.start) && !time.isAfter(expectedRange!.end));

      recordChecks['Record is in range'] = inRange;

      if (!inRange) {
        problems.add('Record is in range');
        messages.add(
          'Timestamp outside expected range:\n'
              'expected range:\n'
              'fetch start time: ${expectedRange!.start.toIso8601String()}\n'
              'fetch end time: ${expectedRange!.end.toIso8601String()}',
        );
      }
    }

    return ValidationResult(
      isValid: problems.isEmpty,
      summary: problems.isEmpty ? 'Valid HRV record' : 'Validation issues found',
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
