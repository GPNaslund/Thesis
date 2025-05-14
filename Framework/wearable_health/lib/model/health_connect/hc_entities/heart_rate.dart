import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';

import 'heart_rate_record_sample.dart';

/// Represents heart rate data from Health Connect.
///
/// Contains heart rate measurements with timestamps and related metadata.
/// Extends [HealthConnectData] base class.
class HealthConnectHeartRate extends HealthConnectData {
  /// Start time of the heart rate measurement session.
  late DateTime startTime;

  /// Optional timezone offset in minutes for the start time.
  late int? startZoneOffset;

  /// End time of the heart rate measurement session.
  late DateTime endTime;

  /// Optional timezone offset in minutes for the end time.
  late int? endZoneOffset;

  /// Collection of individual heart rate measurements.
  late List<HeartRateRecordSample> samples;

  /// Additional metadata associated with this heart rate data.
  late HealthConnectMetadata metadata;

  /// Creates a new heart rate data record with the specified parameters.
  HealthConnectHeartRate({
    required this.startTime,
    this.startZoneOffset,
    required this.endTime,
    this.endZoneOffset,
    required this.samples,
    required this.metadata,
  });

  /// The health metric type for this data.
  ///
  /// Always returns [HealthConnectHealthMetric.heartRate].
  @override
  HealthConnectHealthMetric get metric => HealthConnectHealthMetric.heartRate;

  @override
  String toString() {
    return 'HealthConnectHeartRate(start: ${startTime.toIso8601String()}, end: ${endTime.toIso8601String()}, samples: $samples)';
  }
}
