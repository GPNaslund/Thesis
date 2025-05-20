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

    // === Validating keys ===
    final keyChecks = <String, dynamic>{};
    keyChecks['"heartRateVariability" key exists'] = hrv != null;
    keyChecks['"value" key exists'] = hrv?.value != null;
    keyChecks['"unit" key exists'] = hrv?.unit != null;
    keyChecks['"algorithm" key exists'] = algorithm != null;
    keyChecks['"effectiveTimeFrame" key exists'] = entry.effectiveTimeFrame != null;
    keyChecks['"date_time" key exists'] = time != null;

    // === Validating values ===
    final valueChecks = <String, dynamic>{};
    valueChecks['"value" value'] = hrv?.value;
    valueChecks['"unit" value'] = hrv?.unit;
    valueChecks['"algorithm" value'] = algorithm;
    valueChecks['"date_time" value'] = time?.toIso8601String();

    if (hrv?.value == null || hrv?.value is! num) {
      problems.add('Missing or invalid heartRateVariability value');
    } else {
      final val = hrv!.value!;
      if (val < 5 || val > 250) {
        problems.add('Suspicious HRV value: $val');
      }
    }

    if (hrv?.unit != 'hrv/ms') {
      problems.add('Unexpected unit: ${hrv?.unit}');
    }

    if (algorithm == null) {
      problems.add('Missing algorithm field');
    }

    // === Validating record ===
    final recordChecks = <String, dynamic>{};

    if (time == null) {
      problems.add('Missing effectiveTimeFrame.dateTime');
    } else {
      final iso = time.toIso8601String();
      final isDuplicate = _timestampsSeen.contains(iso);
      recordChecks['Record is not a duplicate'] = !isDuplicate;

      if (isDuplicate) {
        problems.add('Duplicate timestamp: $iso');
      } else {
        _timestampsSeen.add(iso);
      }

      final inRange = expectedRange == null ||
          (!time.isBefore(expectedRange!.start) && !time.isAfter(expectedRange!.end));
      recordChecks['Is record within fetched time range'] = inRange;

      if (!inRange) {
        problems.add('Timestamp outside expected range');
      }
    }

    return ValidationResult(
      isValid: problems.isEmpty,
      summary: problems.isEmpty ? 'Valid HRV record' : 'Validation issues found',
      details: {
        'Validating keys': keyChecks,
        'Validating values': valueChecks,
        'Validating record': recordChecks,
        'problems': problems,
      },
    );
  }
}
