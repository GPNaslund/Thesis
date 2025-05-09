import '../../hk_health_metric.dart';
import '../health_kit_data.dart';
import '../hk_types/hk_quantity_sample.dart';

class HKBodyTemperature extends HealthKitData
{
  late HKQuantitySample data;

  HKBodyTemperature(this.data);

  HKBodyTemperature.fromJson(Map<String, dynamic> jsonData) {
    data = HKQuantitySample.fromJson(jsonData);
  }

  @override
  HealthKitHealthMetric get healthMetric => HealthKitHealthMetric.bodyTemperature;

  @override
  Map<String, dynamic> toJson() {
    return data.toJson();
  }
}