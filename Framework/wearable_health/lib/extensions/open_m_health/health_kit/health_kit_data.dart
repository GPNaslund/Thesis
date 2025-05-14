import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/open_m_health_schema.dart';
import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';
import 'package:wearable_health/model/health_kit/hk_heart_rate.dart';

import '../../../model/health_kit/health_kit_data.dart';

/// Extension that converts [HealthKitData] instances to OpenMHealth schema format.
///
/// Provides the [toOpenMHealth] method to transform different HealthKit data types
/// into standardized OpenMHealth schema representations.
extension OpenMHealthConverter on HealthKitData {
  /// Converts this [HealthKitData] instance to OpenMHealth schema format.
  ///
  /// Supports conversion of:
  /// - [HKHeartRate] → Heart rate schema
  /// - [HKBodyTemperature] → Body temperature schema
  ///
  /// Returns a list of [OpenMHealthSchema] objects.
  ///
  /// Throws [UnimplementedError] for unsupported [HealthKitData] types.
  List<OpenMHealthSchema> toOpenMHealth() {
    if (this is HKHeartRate) {
      return (this as HKHeartRate).toOpenMHealthHeartRate();
    }

    if (this is HKBodyTemperature) {
      return (this as HKBodyTemperature).toOpenMHealthBodyTemperature();
    }

    throw UnimplementedError(
      "Unimplemented HealthKitData type for OpenMHealth conversion",
    );
  }
}
