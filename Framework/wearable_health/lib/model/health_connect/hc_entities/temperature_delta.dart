/// Represents a change in temperature with multiple unit representations.
///
/// Stores temperature delta values in both Celsius and Fahrenheit scales.
class TemperatureDelta {
  /// The temperature change in degrees Celsius (°C).
  late double inCelsius;

  /// The temperature change in degrees Fahrenheit (°F).
  late double inFahrenheit;

  /// Creates a new temperature delta with the specified Celsius and Fahrenheit values.
  ///
  /// Note: This constructor doesn't automatically convert between units.
  /// Both values must be provided in their respective units.
  TemperatureDelta(this.inCelsius, this.inFahrenheit);
}
