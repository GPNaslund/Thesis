import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit.dart';

import 'ieee_1752_schema.dart';

class TemperatureUnitValue extends Ieee1752Schema {
  final num value;
  final TemperatureUnit unit;

  TemperatureUnitValue({
    required this.value,
    required this.unit,
  });

  factory TemperatureUnitValue.fromJson(Map<String, dynamic> json) {
    return TemperatureUnitValue(
      value: json['value'] as num,
      unit: TemperatureUnit.fromJson(json['unit'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit.toJson(),
    };
  }
}