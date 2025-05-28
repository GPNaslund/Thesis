import 'dart:developer'; // Used for logging, primarily for errors or unexpected states during the test setup.

import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
// Enables calling .toOpenMHealthHeartRate() on HKHeartRate objects.

import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_heart_rate_variability.dart';
// Enables calling .toOpenMHealthHeartRateVariability() on HKHeartRateVariability objects.

import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
// Provides enum definitions for HealthKit metric types, used to identify data types.

import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
// Defines the interface for the factory used to create HealthKit data objects.

import 'package:wearable_health_example/models/performance_test_result.dart';
// Defines the structure for returning the performance test results.

/// A class designed to conduct performance tests on the conversion of
/// raw HealthKit data into OpenMHealth compatible formats.
///
/// This class focuses on measuring the time taken for the following operations:
/// 1.  Iterating through a map of health data, where keys are HealthKit metric
///     type definitions (e.g., heart rate, HRV) and values are lists of
///     raw data points for those metrics.
/// 2.  For each raw data point, using an [HKDataFactory] to instantiate a
///     HealthKit-specific data object (e.g., [HKHeartRate], [HKHeartRateVariability]).
/// 3.  Converting these instantiated HealthKit objects into their corresponding
///     OpenMHealth schema representations.
///
/// The time measured specifically covers the OpenMHealth conversion step.
/// The overall results, including an externally provided data fetch time,
/// the total conversion time, and the number of items converted, are compiled
/// into a [PerformanceTestResult].
class HKPerformanceTest {
  /// An instance of [HKDataFactory] used to create structured HealthKit data
  /// objects (like [HKHeartRate] or [HKHeartRateVariability]) from the raw input data maps.
  /// This factory is a prerequisite for the conversion process being timed.
  final HKDataFactory hkDataFactory;

  /// Creates an instance of [HKPerformanceTest].
  ///
  /// Requires an [hkDataFactory] which will be responsible for creating
  /// the intermediate HealthKit data objects from the raw data before they
  /// are converted to the OpenMHealth format.
  HKPerformanceTest(this.hkDataFactory);

  /// Executes the performance test for converting HealthKit data to OpenMHealth format.
  ///
  /// Parameters:
  ///  - [data]: A `Map<String, dynamic>` where keys are HealthKit metric definition
  ///    strings (from [HealthKitHealthMetric.definition]) and values are
  ///    `List<dynamic>` (expected to be lists of maps, each map representing a raw data point).
  ///  - [dataFetchInMs]: An integer representing the time in milliseconds taken to
  ///    fetch the raw [data] before this test is run. This is provided externally.
  ///  - [stopWatch]: A [Stopwatch] instance, which will be reset and used internally
  ///    to measure the cumulative time spent on the OpenMHealth conversion operations.
  ///
  /// The method iterates through heart rate and heart rate variability data points.
  /// For each point, it first creates a HealthKit object using [hkDataFactory],
  /// then times the conversion of this object to its OpenMHealth representation.
  ///
  /// Returns:
  ///  A [PerformanceTestResult] object containing:
  ///    - The `dataFetchInMs` (passed through).
  ///    - The total elapsed time in milliseconds for all OpenMHealth conversions,
  ///      as measured by the [stopWatch].
  ///    - The total `amountConverted` (number of individual data points that underwent
  ///      the OpenMHealth conversion process).
  PerformanceTestResult getPerformanceResults(Map<String, dynamic> data,
      int dataFetchInMs, Stopwatch stopWatch) {
    var amountConverted = 0; // Initialize counter for successfully processed items.

    // Reset the stopwatch to ensure it only measures the operations within this method.
    stopWatch.reset();

    // Iterate over each entry in the input data map.
    // 'key' is the HealthKit metric definition string.
    // 'value' is expected to be a List of raw data point maps for that metric.
    data.forEach((key, value) {
      // Perform a basic type check on the value associated with the key.
      // It should be a list of data points.
      if (value is! List<dynamic>) {
        // Log an error if the value is not of the expected List type.
        log(
            "Invalid value type for key '$key' in HKPerformanceTest: Expected List<dynamic>, got ${value
                .runtimeType}. Skipping this entry.");
        // Continue to the next entry in the map.
        return; // Equivalent to 'continue' in a standard for loop.
      }

      // Process data if the key matches the HealthKit Heart Rate definition.
      if (key == HealthKitHealthMetric.heartRate.definition) {
        // Iterate over each individual heart rate data point (element) in the list.
        value.forEach((element) {
          // Step 1: Create a structured HKHeartRate object from the raw element.
          var obj = hkDataFactory.createHeartRate(element);

          // Step 2: Measure the conversion to OpenMHealth format.
          stopWatch.start(); // Start timing right before the conversion.
          obj.toOpenMHealthHeartRate(); // Perform the conversion.
          stopWatch.stop(); // Stop timing immediately after.

          amountConverted += 1; // Increment the count of converted items.
        });
      }
      // Process data if the key matches the HealthKit Heart Rate Variability definition.
      // Using 'else if' could be slightly more efficient if keys are guaranteed unique,
      // but separate 'if' statements are also fine for clarity given distinct metric definitions.
      else if (key == HealthKitHealthMetric.heartRateVariability.definition) {
        // Iterate over each individual HRV data point (element) in the list.
        value.forEach((element) {
          // Step 1: Create a structured HKHeartRateVariability object from the raw element.
          var obj = hkDataFactory.createHeartRateVariability(element);

          // Step 2: Measure the conversion to OpenMHealth format.
          stopWatch.start(); // Start timing.
          obj.toOpenMHealthHeartRateVariability(); // Perform the conversion.
          stopWatch.stop(); // Stop timing.

          amountConverted += 1; // Increment the count of converted items.
        });
      }
      // Future Extension: Add more 'else if' blocks here to handle other HealthKit metric types
      // if they need to be included in the performance test.
      // Example:
      // else if (key == HealthKitHealthMetric.stepCount.definition) {
      //   value.forEach((element) {
      //     var obj = hkDataFactory.createStepCount(element); // Assuming such a method exists
      //     stopWatch.start();
      //     obj.toOpenMHealthStepCount(); // Assuming such a conversion exists
      //     stopWatch.stop();
      //     amountConverted += 1;
      //   });
      // }
    });

    // Construct and return the performance test results.
    // - dataFetchInMs: The externally provided time for initial data retrieval.
    // - stopWatch.elapsedMilliseconds: The total time accumulated by the stopwatch
    //   for all the OpenMHealth conversion calls made within this method.
    // - amountConverted: The total number of individual data records processed and converted.
    return PerformanceTestResult(
        dataFetchInMs, stopWatch.elapsedMilliseconds, amountConverted);
  }
}