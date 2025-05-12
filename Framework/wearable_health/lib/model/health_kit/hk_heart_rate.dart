import 'package:wearable_health/model/health_kit/hk_entities/hk_quantity_sample.dart';
import 'package:wearable_health/model/health_kit/health_kit_data.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

class HKHeartRate extends HealthKitData {
  late HKQuantitySample data;

  HKHeartRate(this.data);

  @override
  HealthKitHealthMetric get healthMetric => HealthKitHealthMetric.heartRate;
}
