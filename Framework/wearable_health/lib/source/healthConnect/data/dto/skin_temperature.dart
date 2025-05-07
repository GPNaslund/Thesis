import 'package:wearable_health/source/healthConnect/data/dto/metadata.dart';
import 'package:wearable_health/source/healthConnect/data/dto/skin_temperature_delta.dart';
import 'package:wearable_health/source/healthConnect/data/dto/temperature.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';
import 'package:wearable_health/source/health_metric.dart';

class HealthConnectSkinTemperature extends HealthConnectData {
  Temperature? baseline;
  List<SkinTemperatureDelta> deltas;
  DateTime startTime;
  int? startZoneOffset;
  DateTime endTime;
  int? endZoneOffset;
  int measurementLocation;
  HealthConnectMetadata metadata;

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

  factory HealthConnectSkinTemperature.fromMap(
    Map<String, dynamic> serialized,
  ) {
    String startTime = serialized["startTime"];
    int? startZoneOffset = serialized["startZoneOffsetSeconds"];
    String endTime = serialized["endTime"];
    int? endZoneOffset = serialized["endZoneOffsetSeconds"];
    Map<dynamic, dynamic> metadata = serialized["metadata"];
    List<dynamic> deltas = serialized["deltas"];
    Map<dynamic, dynamic>? baseline = serialized["baseline"];
    Temperature? baselineObj;
    if (baseline != null) {
      baselineObj = Temperature(
        baseline["inCelsius"]!,
        baseline["inFahrenheit"]!,
      );
    }
    int measurementLocation = serialized["measurementLocation"];

    HealthConnectMetadata metadataObj = HealthConnectMetadata.fromMap(metadata);
    List<SkinTemperatureDelta> skinTempDeltas = [];
    for (final element in deltas) {
      skinTempDeltas.add(SkinTemperatureDelta.fromMap(element));
    }
    DateTime startTimeObj = DateTime.parse(startTime);
    DateTime endTimeObj = DateTime.parse(endTime);

    return HealthConnectSkinTemperature(
      baseline: baselineObj,
      deltas: skinTempDeltas,
      startTime: startTimeObj,
      startZoneOffset: startZoneOffset,
      endTime: endTimeObj,
      endZoneOffset: endZoneOffset,
      measurementLocation: measurementLocation,
      metadata: metadataObj,
    );
  }

  @override
  HealthMetric get healthMetric =>
      throw HealthConnectHealthMetric.skinTemperature;

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

