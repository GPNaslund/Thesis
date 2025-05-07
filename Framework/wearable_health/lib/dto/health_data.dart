import 'package:wearable_health/source/health_metric.dart';

abstract class HealthData {
  HealthMetric get healthMetric;
  Map<String, dynamic> toJson();
}
