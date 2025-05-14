import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';

class HealthConnectHeartRateVariabilityRmssd implements HealthConnectData {
  DateTime time;
  int? zoneOffset;
  double heartRateVariabilityMillis;
  HealthConnectMetadata metadata;

  HealthConnectHeartRateVariabilityRmssd({
    required this.time,
    this.zoneOffset,
    required this.heartRateVariabilityMillis,
    required this.metadata,
  });

  @override
  HealthConnectHealthMetric get metric => throw UnimplementedError();
}
