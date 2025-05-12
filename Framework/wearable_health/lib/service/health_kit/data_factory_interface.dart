import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';

abstract class HKDataFactory {
  HKHeartRate createHeartRate(Map<String, dynamic> data);
  HKBodyTemperature createBodyTemperature(Map<String, dynamic> data);
}
