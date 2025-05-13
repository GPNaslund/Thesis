import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';

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

  @override
  HealthConnectHealthMetric get metric => HealthConnectHealthMetric.heartRate;

  @override
  String toString() {
    return 'HealthConnectHeartRate(start: ${startTime.toIso8601String()}, end: ${endTime.toIso8601String()}, samples: $samples)';
  }
}