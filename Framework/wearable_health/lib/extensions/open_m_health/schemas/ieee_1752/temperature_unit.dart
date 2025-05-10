import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';

enum TemperatureUnit implements Ieee1752Schema {
  K,
  F,
  C;

  @override
  Map<String, dynamic> toJson() => {
    "name": name
  };

  static TemperatureUnit fromJson(String json) {
    return TemperatureUnit.values.firstWhere((element) => element.name == json,
        orElse: () => throw ArgumentError('Invalid temperature unit: $json'));
  }
}