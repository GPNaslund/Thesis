import 'package:wearable_health/source/healthKit/data/hk_types/hk_quantity_sample.dart';
import 'package:wearable_health/source/healthKit/data/health_kit_data.dart';
import 'package:wearable_health/source/healthKit/hk_health_metric.dart';

class HKHeartRate extends HealthKitData
{
  late HKQuantitySample data;

  HKHeartRate(this.data);

  HKHeartRate.fromJson(Map<String, dynamic> jsonData) {
    data = HKQuantitySample.fromJson(jsonData);
  }

  @override
  HealthKitHealthMetric get healthMetric => HealthKitHealthMetric.heartRate;

  @override
  Map<String, dynamic> toJson() {
    return data.toJson();
  }
}