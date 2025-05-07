import 'package:wearable_health/source/healthConnect/data/dto/temperature_delta.dart';

class SkinTemperatureDelta {
  DateTime time;
  TemperatureDelta delta;

  SkinTemperatureDelta(this.time, this.delta);

  factory SkinTemperatureDelta.fromMap(Map<dynamic, dynamic> serialized) {
    T getField<T>(Map<dynamic, dynamic> map, String key, {bool isNullable = false}) {
      final value = map[key];

      if (value == null) {
        if (isNullable) {
          return null as T;
        } else {
          throw FormatException(
              "SkinTemperatureDelta.fromMap: Missing required field '$key'. Got map: $map");
        }
      }

      if (value is T) {
        return value;
      }

      if (T == int && value is num) {
        return value.toInt() as T;
      }
      if (T == double && value is num) {
        return value.toDouble() as T;
      }

      throw FormatException(
          "SkinTemperatureDelta.fromMap: Invalid type for field '$key'. Expected $T, got ${value.runtimeType}. Value: '$value'");
    }

    final String timeString = getField<String>(serialized, 'time');
    DateTime parsedTime;
    try {
      parsedTime = DateTime.parse(timeString);
    } catch (e) {
      throw FormatException(
          "SkinTemperatureDelta.fromMap: Invalid DateTime-format for 'time': '$timeString'. Error: $e");
    }

    final Map<dynamic, dynamic> deltaMap = getField<Map<dynamic, dynamic>>(serialized, 'delta');

    TemperatureDelta parsedDelta;
    try {
      parsedDelta = TemperatureDelta.fromMap(deltaMap);
    } catch (e) {
      throw FormatException(
          "SkinTemperatureDelta.fromMap: Could not create TemperatureDelta from deltaMap. Internal error: $e");
    }

    return SkinTemperatureDelta(parsedTime, parsedDelta);
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time.toUtc().toIso8601String(),
      "delta": delta.toJson(),
    };
  }
}