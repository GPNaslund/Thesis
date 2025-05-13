import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

/// Base abstract class for all HealthKit data types.
///
/// Serves as a common interface for different health metrics
/// retrieved from HealthKit. All specific health data classes
/// should extend this class.
abstract class HealthKitData {
  /// The specific health metric type this data represents.
  ///
  /// Implementing classes must override this to return their
  /// corresponding [HealthKitHealthMetric] value.
  HealthKitHealthMetric get healthMetric;
}
