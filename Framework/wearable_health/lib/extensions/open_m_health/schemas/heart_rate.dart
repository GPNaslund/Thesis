import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';

/// Represents a heart rate measurement according to the OpenMHealth schema (v2.0).
///
/// Extends [OpenMHealthSchema] to provide a standardized representation of heart rate
/// measurements, including the heart rate value, time frame, and optional context such as
/// relationship to physical activity and sleep.
class OpenMHealthHeartRate extends OpenMHealthSchema {
  /// The heart rate value with its unit (typically "beatsPerMinute").
  final UnitValue heartRate;

  /// The time frame when this measurement was taken.
  final TimeFrame effectiveTimeFrame;

  /// Optional statistical context if this value represents an aggregate of measurements.
  final String? descriptiveStatistic;

  /// Optional relationship of this measurement to physical activity.
  final String? temporalRelationshipToPhysicalActivity;

  /// Optional relationship of this measurement to the subject's sleep cycle.
  final String? temporalRelationshipToSleep;

  /// Creates a new heart rate measurement.
  ///
  /// @param heartRate The heart rate value with its unit.
  /// @param effectiveTimeFrame When the measurement was taken.
  /// @param descriptiveStatistic Optional statistical context for aggregated values.
  /// @param temporalRelationshipToPhysicalActivity Optional relationship to physical activity.
  /// @param temporalRelationshipToSleep Optional relationship to sleep cycle.
  OpenMHealthHeartRate({
    required this.heartRate,
    required this.effectiveTimeFrame,
    this.descriptiveStatistic,
    this.temporalRelationshipToPhysicalActivity,
    this.temporalRelationshipToSleep,
  });

  /// The schema identifier for OpenMHealth heart rate measurements (version 2.0).
  @override
  String get schemaId => "omh:heart-rate:2.0";

  /// Converts this heart rate measurement to its JSON representation.
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    result["heart_rate"] = heartRate.toJson();
    result["time_frame"] = effectiveTimeFrame.toJson();
    if (descriptiveStatistic != null) {
      result["descriptive_statistic"] = descriptiveStatistic;
    }
    if (temporalRelationshipToPhysicalActivity != null) {
      result["temporal_relationship_to_physical_activity"] =
          temporalRelationshipToPhysicalActivity;
    }
    if (temporalRelationshipToSleep != null) {
      result["temporal_relationship_to_sleep"] = temporalRelationshipToSleep;
    }
    return result;
  }
}
