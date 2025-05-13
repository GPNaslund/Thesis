import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature_delta.dart';
import 'package:wearable_health/model/health_connect/hc_entities/temperature.dart';
import 'package:wearable_health/model/health_connect/health_connect_data.dart';

/// Represents skin temperature data from Health Connect.
///
/// Contains temperature measurements with baseline, deltas, timestamps,
/// and related metadata. Extends [HealthConnectData] base class.
class HealthConnectSkinTemperature extends HealthConnectData {
  /// Optional baseline temperature measurement.
  late Temperature? baseline;

  /// Collection of temperature changes relative to the baseline.
  late List<SkinTemperatureDelta> deltas;

  /// Start time of the temperature measurement session.
  late DateTime startTime;

  /// Optional timezone offset in minutes for the start time.
  late int? startZoneOffset;

  /// End time of the temperature measurement session.
  late DateTime endTime;

  /// Optional timezone offset in minutes for the end time.
  late int? endZoneOffset;

  /// Integer code representing where on the body the temperature was measured.
  ///
  /// Refer to Health Connect documentation for specific location codes.
  late int measurementLocation;

  /// Additional metadata associated with this temperature data.
  late HealthConnectMetadata metadata;

  /// Creates a new skin temperature data record with the specified parameters.
  HealthConnectSkinTemperature({
    this.baseline,
    required this.deltas,
    required this.startTime,
    this.startZoneOffset,
    required this.endTime,
    this.endZoneOffset,
    required this.measurementLocation,
    required this.metadata,
  });

  /// The health metric type for this data.
  ///
  /// Always returns [HealthConnectHealthMetric.skinTemperature].
  @override
  HealthConnectHealthMetric get metric =>
      HealthConnectHealthMetric.skinTemperature;
}
