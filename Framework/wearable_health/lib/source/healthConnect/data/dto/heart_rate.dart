import 'dart:developer';

import 'package:wearable_health/source/healthConnect/data/dto/metadata.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';
import 'package:wearable_health/source/health_metric.dart';

import 'heart_rate_record_sample.dart';

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
    final dynamic startTimeValue = serialized["startTimeEpochMs"];
    if (startTimeValue == null || startTimeValue is! num) {
      throw FormatException(
        "Invalid or missing 'startTimeEpochMs' in HeartRate data: Found '$startTimeValue'",
      );
    }
    final DateTime startTime = DateTime.fromMillisecondsSinceEpoch(
      startTimeValue.toInt(),
    );

    final int? startZoneOffset = serialized["startZoneOffset"] as int?;

    final dynamic endTimeValue = serialized["endTimeEpochMs"];
    if (endTimeValue == null || endTimeValue is! num) {
      throw FormatException(
        "Invalid or missing 'endTimeEpochMs' in HeartRate data: Found '$endTimeValue'",
      );
    }
    final DateTime endTime = DateTime.fromMillisecondsSinceEpoch(
      endTimeValue.toInt(),
    );

    final int? endZoneOffset = serialized["endZoneOffset"] as int?;

    final List<HeartRateRecordSample> samples = [];
    final dynamic samplesData = serialized["samples"];
    if (samplesData is List) {
      for (final element in samplesData) {
        if (element is Map) {
          try {
            final Map<String, dynamic> sampleMap = Map<String, dynamic>.from(
              element,
            );
            samples.add(HeartRateRecordSample.fromMap(sampleMap));
          } catch (e) {
            log(
              "Error converting sample item map: $e. Sample item data: $element",
            );
            throw FormatException(
              "Invalid sample item map structure: Could not convert to Map<String, dynamic>. Error: $e. Item: $element",
            );
          }
        } else {
          throw FormatException(
            "Invalid sample item: expected a Map, got ${element?.runtimeType}. Item: $element",
          );
        }
      }
    } else if (samplesData == null) {
      log(
        "Warning: 'samples' list is null in HeartRate data. Proceeding with empty samples.",
      );
    } else {
      throw FormatException(
        "Invalid 'samples' data: expected a List, got ${samplesData?.runtimeType}",
      );
    }

    HealthConnectMetadata metadata;
    final dynamic metadataMapData = serialized["metadata"];
    if (metadataMapData is Map<dynamic, dynamic>) {
      metadata = HealthConnectMetadata.fromMap(metadataMapData);
    } else if (metadataMapData == null) {
      throw FormatException(
        "Missing 'metadata' map in HeartRate data. 'metadata' was null.",
      );
    } else {
      throw FormatException(
        "Invalid 'metadata' type: expected Map<String, dynamic>, got ${metadataMapData?.runtimeType}",
      );
    }

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