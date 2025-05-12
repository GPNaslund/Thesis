import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature_delta.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';

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

  @override
  HealthConnectHealthMetric get metric => HealthConnectHealthMetric.skinTemperature;
}

