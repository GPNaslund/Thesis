import 'package:wearable_health/source/healthConnect/data/dto/metadata.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';

import 'heart_rate_record_sample.dart';

class HealthConnectHeartRate extends HealthConnectData {
  late DateTime startTime;
  late int? startZoneOffset;
  late DateTime endTime;
  late int? endZoneOffset;
  late List<HeartRateRecordSample> samples;
  late HealthConnectMetadata metadata;

  HealthConnectHeartRate({
    required this.startTime,
    this.startZoneOffset,
    required this.endTime,
    this.endZoneOffset,
    required this.samples,
    required this.metadata,
  });


  HealthConnectHeartRate.fromJson(Map<String, dynamic> jsonData) {
    final startTime = _extractDateTimeFromEpochMs(jsonData, "startTimeEpochMs");
    this.startTime = startTime;
    final endTime = _extractDateTimeFromEpochMs(jsonData, "endTimeEpochMs");
    this.endTime = endTime;

    final int? startZoneOffset = jsonData["startZoneOffset"] as int?;
    this.startZoneOffset = startZoneOffset;
    final int? endZoneOffset = jsonData["endZoneOffset"] as int?;
    this.endZoneOffset = endZoneOffset;

    final samples = _extractHeartRateRecordSamples(jsonData);
    this.samples = samples;

    HealthConnectMetadata metadata = _extractMetaData(jsonData);
    this.metadata = metadata;

  }

  DateTime _extractDateTimeFromEpochMs(Map<String, dynamic> jsonData, String keyName) {
    final dynamic timeValue = jsonData[keyName];
    if (timeValue == null || timeValue is! num) {
      throw FormatException(
        "Invalid or missing $keyName in data: Found '$timeValue'",
      );
    }
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
      timeValue.toInt(),
    );
    return dateTime;
  }

  List<HeartRateRecordSample> _extractHeartRateRecordSamples(Map<String, dynamic> jsonData) {
    final List<HeartRateRecordSample> samples = [];
    var samplesData = jsonData["samples"] is List
        ? jsonData["samples"]
        : throw FormatException("Invalid 'samples' data: expected a List, got ${jsonData["samples"].runtimeType}");

      samplesData.forEach((sample) {
          var sampleMap = sample is Map
              ? Map<String, dynamic>.from(sample)
              : throw FormatException("Invalid sample item: expected a Map, got ${sample?.runtimeType}. Item: $sample");
          samples.add(HeartRateRecordSample.fromJson(sampleMap));
      });

      return samples;
  }

  HealthConnectMetadata _extractMetaData(Map<String, dynamic> jsonData) {
    var metadata = jsonData["metadata"] is Map<dynamic, dynamic>
        ? HealthConnectMetadata.fromJson(jsonData["metadata"])
        : throw FormatException("Invalid 'metadata' type: expected Map<String, dynamic>, got ${jsonData["metadata"]?.runtimeType}");
    return metadata;
  }

  @override
  HealthConnectHealthMetric get metric => HealthConnectHealthMetric.heartRate;


  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "startTime": startTime.toUtc().toIso8601String(),
      "endTime": endTime.toUtc().toIso8601String(),
    };

    if (startZoneOffset != null) {
      result["startZoneOffset"] = startZoneOffset;
    }
    if (endZoneOffset != null) {
      result["endZoneOffset"] = endZoneOffset;
    }

    List<Map<String, dynamic>> samplesJson = [];
    for (final element in samples) {
      samplesJson.add(element.toJson());
    }
    result["samples"] = samplesJson;

    result["metadata"] = metadata.toJson();

    return result;
  }
}