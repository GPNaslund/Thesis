import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/ieee_1752_schema.dart';

/// Represents a generic value with its unit as defined by IEEE 1752 mHealth standard.
///
/// Extends [Ieee1752Schema] to provide a standardized representation of numeric measurements
/// with their associated units. This class is used for measurements where specialized
/// unit value classes (like [TemperatureUnitValue]) are not required.
class UnitValue extends Ieee1752Schema {
  /// The numeric value of the measurement.
  final num value;

  /// The unit of measurement as a string (e.g., "beatsPerMinute", "steps").
  final String unit;

  /// Creates a new unit value with the specified value and unit.
  ///
  /// @param value The numeric measurement value.
  /// @param unit The string representation of the measurement unit.
  UnitValue({required this.value, required this.unit});

  /// Converts this unit value to its JSON representation.
  ///
  /// Returns a map with keys "value" and "unit".
  @override
  Map<String, dynamic> toJson() {
    return {"value": value, "unit": unit};
  }
}
