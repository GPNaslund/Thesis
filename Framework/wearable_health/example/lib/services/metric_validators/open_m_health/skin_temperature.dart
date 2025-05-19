// lib/services/metric_validators/open_m_health/skin_temperature.dart

import 'package:flutter/material.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit.dart';
import '../metric_validator.dart';

class SkinTemperatureValidator extends MetricValidator<OpenMHealthBodyTemperature> {
  final DateTimeRange? expectedRange;
  final Set<String> _timestampsSeen = {};

  SkinTemperatureValidator({this.expectedRange});

  @override
  List<ValidationResult> validateAll(List<OpenMHealthBodyTemperature> entries) {
    _timestampsSeen.clear();
    return entries.map(validate).toList();
  }

  @override
  ValidationResult validate(OpenMHealthBodyTemperature entry) {
    final List<String> problems = [];
    final Map<String, dynamic> details = {};

    // --- Validate body_temperature field exists ---
    final bodyTemperature = entry.bodyTemperature;
    if (bodyTemperature == null) {
      return ValidationResult(
        isValid: false,
        summary: 'Missing body_temperature field',
        details: {
          'problems': ['Missing body_temperature field'],
        },
      );
    }

    // --- Validate value ---
    final value = bodyTemperature.value;
    if (value == null || value is! num) {
      problems.add('Missing or invalid value');
    } else if (value < 30 || value > 45) {
      problems.add('Suspicious value: $value is outside of acceptable human range');
    }
    details['value'] = value;

    // --- Validate unit ---
    final unit = bodyTemperature.unit;
    if (unit != TemperatureUnit.C && unit != TemperatureUnit.F && unit != TemperatureUnit.K) {
      problems.add('Unexpected unit: $unit');
    }
    details['unit'] = unit;

    // --- Validate effective_time_frame + date_time ---
    final effectiveTimeFrame = entry.effectiveTimeFrame;
    final dateTime = effectiveTimeFrame.dateTime;

    if (effectiveTimeFrame == null) {
      problems.add('Missing effective_time_frame data');
    } else if (dateTime == null) {
      problems.add('Missing date_time data');
    } else {
      final isoTimestamp = dateTime.toIso8601String();
      details['timestamp'] = isoTimestamp;

      if (_timestampsSeen.contains(isoTimestamp)) {
        problems.add('Duplicate timestamp: $isoTimestamp');
      } else {
        _timestampsSeen.add(isoTimestamp);
      }

      if (expectedRange != null) {
        final start = expectedRange!.start;
        final end = expectedRange!.end;
        if (dateTime.isBefore(start) || dateTime.isAfter(end)) {
          problems.add('Timestamp out of expected range');
        }
      }
    }

    return ValidationResult(
      isValid: problems.isEmpty,
      summary: problems.isEmpty
          ? 'Valid OpenMHealth skin temperature, all checks passed'
          : 'Validation issues found',
      details: {
        'problems': problems,
        ...details,
      },
    );
  }
}
