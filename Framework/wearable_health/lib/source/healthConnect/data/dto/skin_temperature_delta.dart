import 'package:wearable_health/source/healthConnect/data/dto/temperature_delta.dart';

class SkinTemperatureDelta {
  late DateTime time;
  late TemperatureDelta delta;

  SkinTemperatureDelta(this.time, this.delta);

  SkinTemperatureDelta.fromJson(Map<String, dynamic> jsonData) {
    var time = _extractDateTime(jsonData, "time");
    this.time = time;

    var delta = _extractTempDelta(jsonData, "delta");
    this.delta = delta;
  }

  DateTime _extractDateTime(Map<String, dynamic> jsonData, String keyName) {
    var dateTime = jsonData[keyName] is String
        ? DateTime.parse(jsonData[keyName])
        : throw FormatException("Expected string for date time");
    return dateTime;
  }

  TemperatureDelta _extractTempDelta(Map<String, dynamic> jsonData, String keyName) {
    var tempDelta = jsonData[keyName] is Map<dynamic, dynamic>
        ? TemperatureDelta.fromJson(jsonData[keyName])
        : throw FormatException("Expected map for temperature delta");
    return tempDelta;
  }


  Map<String, dynamic> toJson() {
    return {
      "time": time.toUtc().toIso8601String(),
      "delta": delta.toJson(),
    };
  }
}