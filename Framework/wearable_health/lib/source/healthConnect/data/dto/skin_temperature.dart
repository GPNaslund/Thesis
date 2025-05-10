import 'package:wearable_health/source/healthConnect/data/dto/metadata.dart';
import 'package:wearable_health/source/healthConnect/data/dto/skin_temperature_delta.dart';
import 'package:wearable_health/source/healthConnect/data/dto/temperature.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';

class HealthConnectSkinTemperature extends HealthConnectData {
  late Temperature? baseline;
  late List<SkinTemperatureDelta> deltas;
  late DateTime startTime;
  late int? startZoneOffset;
  late DateTime endTime;
  late int? endZoneOffset;
  late int measurementLocation;
  late HealthConnectMetadata metadata;

  HealthConnectSkinTemperature({
    this.baseline,
    required this.deltas,
    required this.startTime,
    this.startZoneOffset,
    required this.endTime,
    this.endZoneOffset,
    required this.measurementLocation,
    required this.metadata,
  });

  HealthConnectSkinTemperature.fromMap(
    Map<String, dynamic> jsonData,
  ) {
    var startTime = _extractDateTime(jsonData, "startTime");
    this.startTime = startTime;
    var endTime = _extractDateTime(jsonData, "endTime");
    this.endTime = endTime;

    var startZoneOffset = _extractZoneOffset(jsonData, "startZoneOffsetSeconds");
    this.startZoneOffset = startZoneOffset;
    var endZoneOffset = _extractZoneOffset(jsonData, "endZoneOffsetSeconds");
    this.endZoneOffset = endZoneOffset;

    var metadata = _extractMetadata(jsonData);
    this.metadata = metadata;

    var deltas = _extractSkinTempDeltas(jsonData);
    this.deltas = deltas;

    var baseline = _extractTemperature(jsonData, "baseline");
    this.baseline = baseline;

    int measurementLocation = jsonData["measurementLocation"] is int
      ? jsonData["measurementLocation"]
      : throw FormatException("Expected measurement location to be an int");
    this.measurementLocation = measurementLocation;

  }

  DateTime _extractDateTime(Map<String, dynamic> jsonData, String keyName) {
    var time = jsonData[keyName] is String
        ? DateTime.parse(jsonData[keyName])
        : throw FormatException("Expected string value");

    return time;
  }

  int? _extractZoneOffset(Map<String, dynamic> jsonData, String keyName) {
    var zoneOffset = jsonData[keyName];
    if (zoneOffset != null && zoneOffset is! num) {
      throw FormatException("Expected null or number");
    }
    return zoneOffset;
  }

  HealthConnectMetadata _extractMetadata(Map<String, dynamic> jsonData) {
    var metadata = jsonData["metadata"] is Map<dynamic, dynamic>
        ? HealthConnectMetadata.fromJson(jsonData["metadata"])
        : throw FormatException("Expected metadata to be Map");
    return metadata;
  }

  List<SkinTemperatureDelta> _extractSkinTempDeltas(Map<String, dynamic> jsonData) {
    var deltasList = jsonData["deltas"] is List<dynamic>
        ? jsonData["deltas"]
        : throw FormatException("Expected deltas to be list");

    List<SkinTemperatureDelta> result = [];
    deltasList.forEach((delta) {
      var skinTempDelta = delta is Map<String, dynamic>
          ? SkinTemperatureDelta.fromJson(delta)
          : throw FormatException("Expected skin temperature delta to be map");
      result.add(skinTempDelta);
    });
    return result;
  }

  Temperature? _extractTemperature(Map<String, dynamic> jsonData, String keyName) {
    if (jsonData[keyName] == null) {
      return null;
    }

    var tempMap = jsonData[keyName] is Map<String, dynamic>
      ? jsonData[keyName]
      : throw FormatException("Expected temperature to be a map");

    var celsius = tempMap["inCelsius"] is double?
      ? tempMap["inCelsius"]
      : throw FormatException("Expected celsius to be a double");

    var fahrenheit = tempMap["inFahrenheit"] is double
      ? tempMap["inFahrenheit"]
      : throw FormatException("Expected fahrenheit to be a double");

    return Temperature(celsius, fahrenheit);
  }

  @override
  HealthConnectHealthMetric get metric => HealthConnectHealthMetric.skinTemperature;

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "startTime": startTime.toUtc().toIso8601String(),
      "endTime": endTime.toUtc().toIso8601String(),
      "measurementLocation": measurementLocation,
      "metadata": metadata.toJson(),
    };

    if (baseline != null) {
      result["baseline"] = baseline!.toJson();
    }
    List<Map<String, dynamic>> deltaMaps = [];
    for (final element in deltas) {
      deltaMaps.add(element.toJson());
    }
    result["deltas"] = deltaMaps;
    if (startZoneOffset != null) {
      result["startZoneOffset"] = startZoneOffset;
    }
    if (endZoneOffset != null) {
      result["endZoneOffset"] = endZoneOffset;
    }
    return result;
  }
}

