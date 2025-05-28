import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';

/// Represents a single Heart Rate Variability (HRV) record focused on the RMSSD (Root Mean Square of Successive Differences) metric,
/// specifically for integration with Health Connect.
///
/// This class encapsulates the RMSSD value, the time of the measurement,
/// optional timezone offset, and associated metadata. It implements [HealthConnectData]
/// to standardize its structure for Health Connect services.
class HealthConnectHeartRateVariabilityRmssd implements HealthConnectData {
  /// The exact date and time when the HRV RMSSD was measured or recorded.
  DateTime time;

  /// Optional. The timezone offset from UTC for the [time] of the measurement, in seconds.
  /// For example, UTC-5 would be -18000.
  int? zoneOffset;

  /// The Heart Rate Variability RMSSD value, measured in milliseconds (ms).
  /// RMSSD is a time-domain measure reflecting short-term, high-frequency HRV.
  double heartRateVariabilityMillis;

  /// Metadata associated with this HRV RMSSD record.
  /// This can include information about the data source, device, recording method, etc.
  HealthConnectMetadata metadata;

  /// Creates an instance of [HealthConnectHeartRateVariabilityRmssd].
  ///
  /// Requires [time], [heartRateVariabilityMillis], and [metadata].
  /// [zoneOffset] is optional.
  HealthConnectHeartRateVariabilityRmssd({
    required this.time,
    this.zoneOffset,
    required this.heartRateVariabilityMillis,
    required this.metadata,
  });

  /// Returns the specific [HealthConnectHealthMetric] type for this data.
  ///
  /// Note: This method currently throws an [UnimplementedError] and needs
  /// to be implemented to return the correct metric type (e.g., `HealthConnectHealthMetric.HRV_RMSSD`).
  @override
  HealthConnectHealthMetric get metric => throw UnimplementedError();

  // TODO: Implement 'metric' getter to return the correct HealthConnectHealthMetric enum.
  // For example: return HealthConnectHealthMetric.HRV_RMSSD;

  /// Converts this [HealthConnectHeartRateVariabilityRmssd] instance to a JSON map.
  ///
  /// The resulting map includes the time (ISO 8601 format), the RMSSD value,
  /// and the metadata. The zone offset is included if available.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      "time": time.toIso8601String(),
      "heartRateVariabilityMillis": heartRateVariabilityMillis,
      "metadata": metadata.toJson()
    };

    if (zoneOffset != null) {
      result["zoneOffset"] = zoneOffset;
    }

    return result;
  }
}