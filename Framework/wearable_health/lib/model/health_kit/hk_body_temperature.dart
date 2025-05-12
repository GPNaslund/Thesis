import 'enums/hk_health_metric.dart';
import 'health_kit_data.dart';
import 'hk_entities/hk_quantity_sample.dart';

class HKBodyTemperature extends HealthKitData {
  late HKQuantitySample data;

  HKBodyTemperature(this.data);

  @override
  HealthKitHealthMetric get healthMetric =>
      HealthKitHealthMetric.bodyTemperature;
}
