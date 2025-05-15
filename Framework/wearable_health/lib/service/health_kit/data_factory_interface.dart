import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate_variability.dart';

/// Defines interface for creating HealthKit (iOS) data objects from JSON map data.
/// Abstracts the creation logic for various health metrics collected from iOS devices.
abstract class HKDataFactory {
  /// Creates a heart rate record from HealthKit JSON data.
  HKHeartRate createHeartRate(Map<String, dynamic> data);

  /// Creates a body temperature record from HealthKit JSON data.
  HKBodyTemperature createBodyTemperature(Map<String, dynamic> data);

  /// Creates a heart rate variability record from HealthKit JSON data.
  HkHeartRateVariability createHeartRateVariability(Map<String, dynamic> data);
}
