import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';
import 'package:wearable_health/source/json/json_converter.dart';

abstract class HealthConnectData with JsonConverter {
  HealthConnectHealthMetric get metric;
}
