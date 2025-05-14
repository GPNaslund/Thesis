import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_measurement_method.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/temporal_relationship_to_physical_activity.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/temporal_relationship_to_sleep.dart';

import 'heart_rate_variability_algorithm.dart';
import 'ieee_1752/descriptive_statistic.dart';
import 'ieee_1752/time_frame.dart';
import 'ieee_1752/unit_value.dart';

class OpenMHealthHeartRateVariability extends OpenMHealthSchema {
  final UnitValue heartRateVariability;
  final HrvAlgorithm algorithm;
  final String? algorithmDetails;
  final HrvMeasurementMethod? measurementMethod;
  final TimeFrame effectiveTimeFrame;
  final DescriptiveStatistic? descriptiveStatistic;
  final TemporalRelationshipToPhysicalActivity? temporalRelationshipToPhysicalActivity;
  final TemporalRelationshipToSleep? temporalRelationshipToSleep;

  OpenMHealthHeartRateVariability({
    required this.heartRateVariability,
    required this.algorithm,
    required this.effectiveTimeFrame,
    this.algorithmDetails,
    this.measurementMethod,
    this.descriptiveStatistic,
    this.temporalRelationshipToPhysicalActivity,
    this.temporalRelationshipToSleep,
  });


  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "heartRateVariability": heartRateVariability.toJson(),
      "algorithm": algorithm.value,
      "effectiveTimeFrame": effectiveTimeFrame.toJson(),
    };

    if (algorithmDetails != null) {
      result["algorithmDetails"] = algorithmDetails;
    }

    if (measurementMethod != null) {
      result["measurementMethod"] = measurementMethod!.value;
    }

    if (descriptiveStatistic != null) {
      result["descriptiveStatistic"] = descriptiveStatistic!.toJson();
    }

    if (temporalRelationshipToPhysicalActivity != null) {
      result["temporalRelationshipToPhysicalActivity"] = temporalRelationshipToPhysicalActivity!.value;
    }

    if (temporalRelationshipToSleep != null) {
      result["temporalRelationshipToSleep"] = temporalRelationshipToSleep!.jsonValue;
    }

    return result;
  }

  @override
  String get schemaId => "omh:heart-rate-variability:1.0";


}

