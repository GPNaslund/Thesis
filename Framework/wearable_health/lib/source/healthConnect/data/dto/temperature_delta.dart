class TemperatureDelta {
  double inCelsius;
  double inFahrenheit;

  TemperatureDelta(this.inCelsius, this.inFahrenheit);

  factory TemperatureDelta.fromMap(Map<dynamic, dynamic> serialized) {
    T getField<T>(Map<dynamic, dynamic> map, String key, {bool isNullable = false}) {
      final value = map[key];

      if (value == null) {
        if (isNullable) {
          return null as T;
        } else {
          throw FormatException(
              "TemperatureDelta.fromMap: Missing required field '$key'. Received map: $map");
        }
      }

      if (value is T) {
        return value;
      }

      if (T == double && value is num) {
        return value.toDouble() as T;
      }
      if (T == int && value is num) {
        return value.toInt() as T;
      }

      throw FormatException(
          "TemperatureDelta.fromMap: Invalid type for field '$key'. Expected $T, got ${value.runtimeType}. Value: '$value'");
    }

    final double celsius = getField<double>(serialized, 'inCelsius');
    final double fahrenheit = getField<double>(serialized, 'inFahrenheit');

    return TemperatureDelta(celsius, fahrenheit);
  }

  Map<String, dynamic> toJson() {
    return {
      "inCelsius": inCelsius,
      "inFahrenheit": inFahrenheit,
    };
  }
}