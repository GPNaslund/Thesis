import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';

/// Base abstract class for all Health Connect data types.
///
/// Serves as a common interface for different health metrics
/// retrieved from Health Connect. All specific health data classes
/// should extend this class.
abstract class HealthConnectData {
  /// The specific health metric type this data represents.
  ///
  /// Implementing classes must override this to return their
  /// corresponding [HealthConnectHealthMetric] value.
  HealthConnectHealthMetric get metric;
}
