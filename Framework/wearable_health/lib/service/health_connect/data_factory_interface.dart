import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';

/// Defines interface for creating Health Connect (Android) data objects from JSON map data.
/// Abstracts the creation logic for various health metrics collected from Android devices.
abstract class HCDataFactory {
  /// Creates a heart rate record with samples from Health Connect JSON data.
  HealthConnectHeartRate createHeartRate(Map<String, dynamic> data);

  /// Creates a skin temperature record with baseline and delta measurements
  /// from Health Connect JSON data.
  HealthConnectSkinTemperature createSkinTemperature(Map<String, dynamic> data);
}
