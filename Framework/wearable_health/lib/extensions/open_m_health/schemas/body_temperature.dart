import 'package:wearable_health/extensions/open_m_health/schemas/temporal_relationship_to_sleep.dart';

import 'ieee_1752/descriptive_statistic.dart';
import 'ieee_1752/temperature_unit_value.dart';
import 'ieee_1752/time_frame.dart';
import 'measurement_location.dart';
import 'open_m_health_schema.dart';

class OpenMHealthBodyTemperature extends OpenMHealthSchema {
  final TemperatureUnitValue bodyTemperature;
  final TimeFrame effectiveTimeFrame;
  final DescriptiveStatistic? descriptiveStatistic;
  final MeasurementLocation? measurementLocation;
  final TemporalRelationshipToSleep? temporalRelationshipToSleep;

  OpenMHealthBodyTemperature({
    required this.bodyTemperature,
    required this.effectiveTimeFrame,
    this.descriptiveStatistic,
    this.measurementLocation,
    this.temporalRelationshipToSleep,
  });

  @override
  String get schemaId => "omh:body-temperature:4.0";

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