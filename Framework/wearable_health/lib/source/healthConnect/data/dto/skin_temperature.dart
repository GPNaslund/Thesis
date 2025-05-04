import 'package:wearable_health/source/healthConnect/data/dto/metadata.dart';
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
    int? startZoneOffset = serialized["startZoneOffset"];
    String endTime = serialized["endTime"];
    int? endZoneOffset = serialized["endZoneOffset"];
    Map<String, dynamic> metadata = serialized["metadata"];
    List<Map<String, dynamic>> deltas = serialized["deltas"];
    Map<String, double> baseline = serialized["baseline"];
    Temperature baselineObj = Temperature(
      baseline["inCelcius"]!,
      baseline["inFahrenheit"]!,
    );
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
}

class Temperature {
  double inCelcius;
  double inFahrenheit;

  Temperature(this.inCelcius, this.inFahrenheit);
}

class SkinTemperatureDelta {
  DateTime time;
  TemperatureDelta delta;

  SkinTemperatureDelta(this.time, this.delta);

  factory SkinTemperatureDelta.fromMap(Map<String, dynamic> serialized) {
    DateTime time = DateTime.parse(serialized["time"]);
    TemperatureDelta delta = TemperatureDelta(
      serialized["delta"]["inCelcius"],
      serialized["delta"]["inFahrenheit"],
    );
    return SkinTemperatureDelta(time, delta);
  }
}

class TemperatureDelta {
  double inCelcius;
  double inFahrenheit;

  TemperatureDelta(this.inCelcius, this.inFahrenheit);
}
