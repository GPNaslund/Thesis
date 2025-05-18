import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';

/// Represents temperature measurement units as defined by IEEE 1752 mHealth standard.
///
/// Implements [Ieee1752Schema] to provide standardized temperature unit serialization.
enum TemperatureUnit implements Ieee1752Schema {
  /// Kelvin temperature scale.
  K,

  /// Fahrenheit temperature scale.
  F,

  /// Celsius temperature scale.
  C;

  /// Converts this temperature unit to its JSON representation.
  ///
  /// Returns a map with the key "name" and the value as the
  /// string name of this temperature unit.
  @override
  Map<String, dynamic> toJson() => {"unit": name};

  /// Creates a temperature unit from its JSON string representation.
  ///
  /// @param json The string name of the temperature unit.
  /// @return The corresponding [TemperatureUnit] value.
  /// @throws ArgumentError if the string does not match any valid temperature unit.
  static TemperatureUnit fromJson(String json) {
    return TemperatureUnit.values.firstWhere(
      (element) => element.name == json,
      orElse: () => throw ArgumentError('Invalid temperature unit: $json'),
    );
  }
}
