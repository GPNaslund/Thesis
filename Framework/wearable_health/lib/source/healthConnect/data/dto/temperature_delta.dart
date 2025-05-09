class TemperatureDelta {
  late double inCelsius;
  late double inFahrenheit;

  TemperatureDelta(this.inCelsius, this.inFahrenheit);

  TemperatureDelta.fromJson(Map<String, dynamic> jsonData) {
    var inCelsius = _extractDouble(jsonData, "inCelsius");
    this.inCelsius = inCelsius;

    var inFahrenheit = _extractDouble(jsonData, "inFahrenheit");
    this.inFahrenheit = inFahrenheit;
  }

  double _extractDouble(Map<String, dynamic> jsonData, String keyName) {
    var value = jsonData[keyName] is double
        ? jsonData[keyName]
        : throw FormatException("Expected value to be of type double");
    return value;
  }

  Map<String, dynamic> toJson() {
    return {
      "inCelsius": inCelsius,
      "inFahrenheit": inFahrenheit,
    };
  }

}