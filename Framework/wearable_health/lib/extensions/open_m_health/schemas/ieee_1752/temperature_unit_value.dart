import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit.dart';

import 'ieee_1752_schema.dart';

/// Represents a temperature value with its unit as defined by IEEE 1752 mHealth standard.
///
/// Extends [Ieee1752Schema] to provide a standardized representation of temperature measurements
/// with their associated units (Kelvin, Fahrenheit, or Celsius).
class TemperatureUnitValue extends Ieee1752Schema {
  /// The numeric value of the temperature measurement.
  final num value;

  /// The unit of measurement for the temperature ([TemperatureUnit]).
  final TemperatureUnit unit;

  /// Creates a new temperature unit value with the specified value and unit.
  ///
  /// @param value The numeric temperature value.
  /// @param unit The temperature unit (K, F, or C).
  TemperatureUnitValue({required this.value, required this.unit});

  /// Creates a temperature unit value from its JSON representation.
  ///
  /// @param json A map containing 'value' (numeric) and 'unit' (string) keys.
  /// @return A new [TemperatureUnitValue] instance.
  /// @throws ArgumentError if the unit string is invalid.
  factory TemperatureUnitValue.fromJson(Map<String, dynamic> json) {
    return TemperatureUnitValue(
      value: json['value'] as num,
      unit: TemperatureUnit.fromJson(json['unit'] as String),
    );
  }

  /// Converts this temperature unit value to its JSON representation.
  ///
  /// Returns a map with keys 'value' and 'unit'.
  @override
  Map<String, dynamic> toJson() {
    return {'value': value, 'unit': unit.name };
  }
}
