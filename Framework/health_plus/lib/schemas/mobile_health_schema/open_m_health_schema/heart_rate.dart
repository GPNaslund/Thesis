import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/time_frame.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/unit_value.dart';
import 'package:health_plus/schemas/mobile_health_schema/open_m_health_schema/open_m_health_schema.dart';

class HeartRate extends OpenMHealthSchema {
  final UnitValue heartRate;
  final TimeFrame effectiveTimeFrame;
  final String? descriptiveStatistic;
  final String? temporalRelationshipToPhysicalActivity;
  final String? temporalRelationshipToSleep;

  HeartRate({
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
