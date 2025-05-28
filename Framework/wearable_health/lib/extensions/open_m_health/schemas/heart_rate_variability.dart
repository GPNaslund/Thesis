import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability_measurement_method.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/temporal_relationship_to_physical_activity.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/temporal_relationship_to_sleep.dart';

import 'heart_rate_variability_algorithm.dart';
import 'ieee_1752/descriptive_statistic.dart';
import 'ieee_1752/time_frame.dart';
import 'ieee_1752/unit_value.dart';

/// Represents a heart rate variability (HRV) measurement according to the OpenMHealth schema (v1.0).
///
/// Extends [OpenMHealthSchema] to provide a standardized representation of HRV
/// measurements. This includes the HRV value, the algorithm used for its calculation,
/// the time frame of the measurement, and optional contextual information such as
/// algorithm details, measurement method, and relationships to physical activity or sleep.
class OpenMHealthHeartRateVariability extends OpenMHealthSchema {
  /// The heart rate variability value with its unit (e.g., "ms" for RMSSD, SDNN).
  final UnitValue heartRateVariability;

  /// The algorithm used to calculate the heart rate variability (e.g., RMSSD, SDNN).
  final HrvAlgorithm algorithm;

  /// Optional additional details about the algorithm used, if any.
  final String? algorithmDetails;

  /// Optional method used to measure the heart rate variability.
  final HrvMeasurementMethod? measurementMethod;

  /// The time frame during which this heart rate variability measurement was effectively taken or calculated.
  final TimeFrame effectiveTimeFrame;

  /// Optional descriptive statistic if this value is an aggregate (e.g., average, median) of multiple HRV measurements.
  final DescriptiveStatistic? descriptiveStatistic;

  /// Optional temporal relationship of this HRV measurement to physical activity.
  final TemporalRelationshipToPhysicalActivity? temporalRelationshipToPhysicalActivity;

  /// Optional temporal relationship of this HRV measurement to sleep.
  final TemporalRelationshipToSleep? temporalRelationshipToSleep;

  /// Creates an instance of [OpenMHealthHeartRateVariability].
  ///
  /// Requires [heartRateVariability], [algorithm], and [effectiveTimeFrame].
  /// All other parameters are optional.
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

