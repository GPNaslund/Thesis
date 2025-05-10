import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';

class UnitValue extends Ieee1752Schema {
  final num value;
  final String unit;

  UnitValue({required this.value, required this.unit});

  @override
  Map<String, dynamic> toJson() {
    return {"value": value, "unit": unit};
  }
}
