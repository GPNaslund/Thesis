import 'dart:developer'; // Used for logging, primarily for errors or unexpected states.

import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health_example/models/performance_test_result.dart';

/// A class designed to perform and measure the performance of converting
/// raw health data (structured as a map) into OpenMHealth compatible formats.
///
/// This test specifically focuses on:
/// 1.  Iterating through a map of health data where keys represent metric types
///     (e.g., heart rate, heart rate variability) and values are lists of
///     data points for those metrics.
/// 2.  For each data point, using an [HCDataFactory] to create a Health Connect
///     specific data object.
/// 3.  Measuring the time taken to convert these Health Connect objects into
///     their corresponding OpenMHealth schema representations.
///
/// The results, including data fetch time (provided externally), total conversion time,
/// and the number of successfully converted items, are encapsulated in a
/// [PerformanceTestResult] object.
class HCPerformanceTest {
  /// A factory instance used to create Health Connect data objects from raw data.
  /// This is essential for the first step of the conversion process being tested.
  final HCDataFactory hcDataFactory;

  /// Creates an instance of [HCPerformanceTest].
  ///
  /// Requires an [hcDataFactory] which will be used to instantiate
  /// Health Connect data objects from the raw input data during the performance test.
  HCPerformanceTest(this.hcDataFactory);

  /// Executes the performance test for data conversion.
  ///
  /// Takes a map of [data] (where keys are metric definitions and values are lists
  /// of raw data points), the [dataFetchInMs] (time taken to fetch this data,
  /// measured externally), and a [stopWatch] instance to measure conversion times.
  ///
  /// The method iterates through heart rate and heart rate variability data,
  /// converts each point to its OpenMHealth equivalent, and records the time taken.
  ///
  /// Returns a [PerformanceTestResult] containing:
  ///  - The initial data fetch time.
  ///  - The total time spent on OpenMHealth conversions.
  ///  - The total number of data points converted.
  PerformanceTestResult getPerformanceResults(Map<String, dynamic> data,
      int dataFetchInMs, Stopwatch stopWatch) {
    var amountConverted = 0; // Counter for the total number of items successfully converted.

    // Reset the stopwatch before starting conversion timing.
    // This ensures only the conversion part is measured by this stopwatch instance.
    stopWatch.reset();

    // Iterate through each entry (metric type and its list of data points) in the input map.
    data.forEach((key, value) {
      // Basic validation: ensure the value associated with a metric key is a list.
      if (value is! List<dynamic>) {
        log(
            "Invalid value type for key '$key': Expected List<dynamic>, got ${value
                .runtimeType}. Skipping this entry.");
        return; // Skip this entry if the value is not a list.
      }

      // Process Heart Rate data points.
      if (key == HealthConnectHealthMetric.heartRate.definition) {
        // Iterate over each raw heart rate data point in the list.
        value.forEach((element) {
          // Create a Health Connect specific heart rate object using the factory.
          var obj = hcDataFactory.createHeartRate(element);

          // Start the stopwatch just before the OpenMHealth conversion.
          stopWatch.start();
          // Perform the conversion to OpenMHealth format.
          obj.toOpenMHealthHeartRate();
          // Stop the stopwatch immediately after the conversion.
          stopWatch.stop();

          amountConverted += 1; // Increment the count of converted items.
        });
      }
      // Process Heart Rate Variability data points.
      else
      if (key == HealthConnectHealthMetric.heartRateVariability.definition) {
        // Iterate over each raw HRV data point in the list.
        value.forEach((element) {
          // Create a Health Connect specific HRV object using the factory.
          var obj = hcDataFactory.createHeartRateVariability(element);

          // Start the stopwatch just before the OpenMHealth conversion.
          stopWatch.start();
          // Perform the conversion to OpenMHealth format.
          // Note: This calls 'toOpenMHealthHeartRateVariabilityRmssd()'.
          obj.toOpenMHealthHeartRateVariabilityRmssd();
          // Stop the stopwatch immediately after the conversion.
          stopWatch.stop();

          amountConverted += 1; // Increment the count of converted items.
        });
      }
      // Future: Add handling for other HealthConnectHealthMetric types here
      // else if (key == HealthConnectHealthMetric.someOtherMetric.definition) { ... }
    });

    // Return the aggregated performance results.
    // dataFetchInMs: Provided time for fetching the initial data.
    // stopWatch.elapsedMilliseconds: Total time measured by the stopwatch for all conversions.
    // amountConverted: Total number of individual data points converted to OpenMHealth.
    return PerformanceTestResult(
        dataFetchInMs, stopWatch.elapsedMilliseconds, amountConverted);
  }
}