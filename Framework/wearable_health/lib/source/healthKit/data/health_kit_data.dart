import 'package:wearable_health/source/healthKit/hk_health_metric.dart';
import 'package:wearable_health/source/json/json_converter.dart';

abstract class HealthKitData with JsonConverter {
  HealthKitHealthMetric get healthMetric;
}