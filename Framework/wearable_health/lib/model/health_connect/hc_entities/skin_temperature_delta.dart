import 'package:wearable_health/model/health_connect/hc_entities/temperature_delta.dart';

/// Represents a single skin temperature delta measurement.
///
/// Contains a timestamp and the measured temperature change relative to a baseline.
class SkinTemperatureDelta {
  /// The timestamp when this temperature delta was recorded.
  late DateTime time;

  /// The measured change in temperature relative to the baseline.
  late TemperatureDelta delta;

  /// Creates a new skin temperature delta with the specified time and value.
  SkinTemperatureDelta(this.time, this.delta);
}
