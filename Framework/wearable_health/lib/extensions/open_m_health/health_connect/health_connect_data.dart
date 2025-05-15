import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_skin_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate.dart';
import 'package:wearable_health/model/health_connect/hc_entities/heart_rate_variability_rmssd.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';

/// Extension that converts [HealthConnectData] instances to OpenMHealth schema format.
///
/// Provides the [toOpenMHealth] method to transform different Health Connect data types
/// into standardized OpenMHealth schema representations.
extension OpenMHealthConverter on HealthConnectData {
  /// Converts this [HealthConnectData] instance to OpenMHealth schema format.
  ///
  /// Supports conversion of:
  /// - [HealthConnectHeartRate] → Heart rate schema
  /// - [HealthConnectSkinTemperature] → Body temperature schema
  ///
  /// Returns a list of [OpenMHealthSchema] objects.
  ///
  /// Throws [UnimplementedError] for unsupported [HealthConnectData] types.
  List<OpenMHealthSchema> toOpenMHealth() {
    if (this is HealthConnectHeartRate) {
      return (this as HealthConnectHeartRate).toOpenMHealthHeartRate();
    }

    if (this is HealthConnectSkinTemperature) {
      return (this as HealthConnectSkinTemperature)
          .toOpenMHealthBodyTemperature();
    }

    if (this is HealthConnectHeartRateVariabilityRmssd) {
      return (this as HealthConnectHeartRateVariabilityRmssd).toOpenMHealthHeartRateVariabilityRmssd();
    }

    throw UnimplementedError("Unimplemented HealthDataType");
  }
}
