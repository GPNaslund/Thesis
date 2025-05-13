import 'package:wearable_health/extensions/open_m_health/schemas/temporal_relationship_to_sleep.dart';

import 'ieee_1752/descriptive_statistic.dart';
import 'ieee_1752/temperature_unit_value.dart';
import 'ieee_1752/time_frame.dart';
import 'measurement_location.dart';
import 'open_m_health_schema.dart';

/// Represents a body temperature measurement according to the OpenMHealth schema (v4.0).
///
/// Extends [OpenMHealthSchema] to provide a standardized representation of body temperature
/// measurements, including the temperature value, time frame, and optional context such as
/// measurement location and relationship to sleep.
class OpenMHealthBodyTemperature extends OpenMHealthSchema {
  /// The temperature value with its unit (typically Celsius or Fahrenheit).
  final TemperatureUnitValue bodyTemperature;

  /// The time frame when this measurement was taken.
  final TimeFrame effectiveTimeFrame;

  /// Optional statistical context if this value represents an aggregate of measurements.
  final DescriptiveStatistic? descriptiveStatistic;

  /// Optional anatomical location where the temperature was measured.
  final MeasurementLocation? measurementLocation;

  /// Optional relationship of this measurement to the subject's sleep cycle.
  final TemporalRelationshipToSleep? temporalRelationshipToSleep;

  /// Creates a new body temperature measurement.
  ///
  /// @param bodyTemperature The temperature value with its unit.
  /// @param effectiveTimeFrame When the measurement was taken.
  /// @param descriptiveStatistic Optional statistical context for aggregated values.
  /// @param measurementLocation Optional location where temperature was measured.
  /// @param temporalRelationshipToSleep Optional relationship to sleep cycle.
  OpenMHealthBodyTemperature({
    required this.bodyTemperature,
    required this.effectiveTimeFrame,
    this.descriptiveStatistic,
    this.measurementLocation,
    this.temporalRelationshipToSleep,
  });

  /// The schema identifier for OpenMHealth body temperature measurements (version 4.0).
  @override
  String get schemaId => "omh:body-temperature:4.0";

  /// Converts this body temperature measurement to its JSON representation.
  ///
  /// Returns a map with the following keys:
  /// - 'body_temperature': The temperature value and unit
  /// - 'effective_time_frame': When the measurement was taken
  /// - 'descriptive_statistic': Optional statistical context (if provided)
  /// - 'measurement_location': Optional anatomical location (if provided)
  /// - 'temporal_relationship_to_sleep': Optional relationship to sleep (if provided)
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'body_temperature': bodyTemperature.toJson(),
      'effective_time_frame': effectiveTimeFrame.toJson(),
    };
    if (descriptiveStatistic != null) {
      data['descriptive_statistic'] = descriptiveStatistic!.toJson();
    }
    if (measurementLocation != null) {
      data['measurement_location'] = measurementLocation!.toJson();
    }
    if (temporalRelationshipToSleep != null) {
      data['temporal_relationship_to_sleep'] =
          temporalRelationshipToSleep!.toJson();
    }
    return data;
  }
}
