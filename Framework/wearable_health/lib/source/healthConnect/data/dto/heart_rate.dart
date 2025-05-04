import 'package:wearable_health/source/healthConnect/data/dto/metadata.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';
import 'package:wearable_health/source/health_metric.dart';

class HealthConnectHeartRate extends HealthConnectData {
  DateTime startTime;
  int? startZoneOffset;
  DateTime endTime;
  int? endZoneOffset;
  List<HeartRateRecordSample> samples;
  HealthConnectMetadata metadata;

  HealthConnectHeartRate({
    required this.startTime,
    this.startZoneOffset,
    required this.endTime,
    this.endZoneOffset,
    required this.samples,
    required this.metadata,
  });

  factory HealthConnectHeartRate.fromMap(Map<String, dynamic> serialized) {
    String startTimeString = serialized["startTime"];
    DateTime startTime = DateTime.parse(startTimeString);
    int? startZoneOffset = serialized["startZoneOffset"];
    String endTimeString = serialized["endTime"];
    DateTime endTime = DateTime.parse(endTimeString);
    int? endZoneOffset = serialized["endZoneOffset"];
    List<HeartRateRecordSample> samples = [];
    for (final element in serialized["samples"]) {
      samples.add(HeartRateRecordSample.fromMap(element));
    }
    HealthConnectMetadata metadata = HealthConnectMetadata.fromMap(
      serialized["metadata"],
    );

    return HealthConnectHeartRate(
      startTime: startTime,
      startZoneOffset: startZoneOffset,
      endTime: endTime,
      endZoneOffset: endZoneOffset,
      samples: samples,
      metadata: metadata,
    );
  }

  @override
  HealthMetric get healthMetric => throw HealthConnectHealthMetric.heartRate;
}

class HeartRateRecordSample {
  DateTime time;
  int beatsPerMinute;

  HeartRateRecordSample(this.time, this.beatsPerMinute);

  factory HeartRateRecordSample.fromMap(Map<String, dynamic> serialized) {
    return HeartRateRecordSample(
      serialized["time"],
      serialized["beatsPerMinute"],
    );
  }
}
