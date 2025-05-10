class Temperature {
  double inCelsius;
  double inFahrenheit;

  Temperature(this.inCelsius, this.inFahrenheit);

  Map<String, dynamic> toJson() {
    return {
      "inCelsius": inCelsius,
      "inFahrenheit": inFahrenheit,
    };
  }
}