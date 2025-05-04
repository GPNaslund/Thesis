import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/unit_value.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';

class OpenMHealthHeartRate extends OpenMHealthSchema {
  final UnitValue heartRate;
  final TimeFrame effectiveTimeFrame;
  final String? descriptiveStatistic;
  final String? temporalRelationshipToPhysicalActivity;
  final String? temporalRelationshipToSleep;

  OpenMHealthHeartRate({
    required this.heartRate,
    required this.effectiveTimeFrame,
    this.descriptiveStatistic,
    this.temporalRelationshipToPhysicalActivity,
    this.temporalRelationshipToSleep,
  });

  @override
  String get schemaId => "omh:heart-rate:2.0";

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
