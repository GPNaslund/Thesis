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
    final details = <String, dynamic>{};

    final hrv = entry.heartRateVariability;
    final algorithm = entry.algorithm;
    final time = entry.effectiveTimeFrame.dateTime;

    // --- Check HRV value ---
    if (hrv == null || hrv.value == null || hrv.value is! num) {
      problems.add('Missing or invalid heartRateVariability value');
    } else {
      final val = hrv.value!;
      details['value'] = val;
      if (val < 5 || val > 250) {
        problems.add('Suspicious HRV value: $val');
      }
    }

    // --- Check unit ---
    final unit = hrv?.unit;
    details['unit'] = unit;
    if (unit != 'hrv/ms') {
      problems.add('Unexpected unit: $unit');
    }

    // --- Check algorithm ---
    if (algorithm == null) {
      problems.add('Missing algorithm field');
    }
    details['algorithm'] = algorithm;

    // --- Check timestamp ---
    if (time == null) {
      problems.add('Missing effectiveTimeFrame.dateTime');
    } else {
      final iso = time.toIso8601String();
      details['timestamp'] = iso;

      if (_timestampsSeen.contains(iso)) {
        problems.add('Duplicate timestamp: $iso');
      } else {
        _timestampsSeen.add(iso);
      }

      if (expectedRange != null) {
        if (time.isBefore(expectedRange!.start) || time.isAfter(expectedRange!.end)) {
          problems.add('Timestamp outside expected range');
        }
      }
    }

    return ValidationResult(
      isValid: problems.isEmpty,
      summary: problems.isEmpty ? 'Valid HRV record' : 'Validation issues found',
      details: {
        'problems': problems,
        ...details,
      },
    );
  }
}
