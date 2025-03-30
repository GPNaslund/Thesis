import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/ieee_1752_schema.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/time_frame.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/unit_value.dart';

class PhysicalActivity extends Ieee1752Schema {
  final String activityName;
  final TimeFrame effectiveTimeFrame;
  final UnitValue? baseMovementQuantity;

  PhysicalActivity({
    required this.activityName,
    required this.effectiveTimeFrame,
    this.baseMovementQuantity,
  });

  @override
  String get schemaId =>
      "https://w3id.org/ieee/ieee-1752-schema/physical-activity.json";

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    result["activity_name"] = activityName;
    result["effective_time_frame"] = effectiveTimeFrame;
    if (baseMovementQuantity != null) {
      result["base_movement_quantity"] = baseMovementQuantity;
    }
    return result;
  }
}
