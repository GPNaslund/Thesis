/// Represents a temperature measurement with multiple unit representations.
///
/// Stores temperature values in both Celsius and Fahrenheit scales.
class Temperature {
  /// The temperature value in degrees Celsius (°C).
  double inCelsius;

  /// The temperature value in degrees Fahrenheit (°F).
  double inFahrenheit;

  /// Creates a new temperature with the specified Celsius and Fahrenheit values.
  ///
  /// Note: This constructor doesn't automatically convert between units.
  /// Both values must be provided in their respective units.
  Temperature(this.inCelsius, this.inFahrenheit);
}
