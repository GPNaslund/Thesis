import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

// Provides enum definitions for HealthKit metric types, used to identify
// the type of data being counted (e.g., HeartRate, HeartRateVariability).

import 'package:wearable_health_example/models/record_count_result.dart';

// Defines the structure (RecordCountResult) used to return the counts
// of different types of records.


/// A utility class designed to count the number of records for specific
/// Apple HealthKit health metrics within a given dataset.
///
/// This class processes a map where:
///  - Keys are strings representing HealthKit metric type definitions
///    (e.g., "HKQuantityTypeIdentifierHeartRate" from [HealthKitHealthMetric.definition]).
///  - Values are lists of individual data records (each record typically being a map
///    itself) corresponding to that metric type.
///
/// It iterates through this data and tallies the number of records found for
/// heart rate and heart rate variability.
class HKRecordCount {
  /// Calculates and returns the total number of Heart Rate (HR) and
  /// Heart Rate Variability (HRV) records present in the provided [data] map.
  ///
  /// The input [data] map is expected to adhere to the following structure:
  ///  - Keys: `String` values that match one of the `definition` strings from
  ///    the [HealthKitHealthMetric] enum (e.g., `HealthKitHealthMetric.heartRate.definition`).
  ///  - Values: `List<Map<String, dynamic>>`, where each `Map<String, dynamic>`
  ///    in the list represents a single raw data record for the HealthKit metric
  ///    type specified by the key.
  ///
  /// The method iterates through each entry in the `data` map. If an entry's key
  /// matches the definition for heart rate or heart rate variability, it then
  /// counts the number of elements (records) in the associated list.
  ///
  /// Returns:
  ///  A [RecordCountResult] object containing two main counts:
  ///    - The total number of heart rate records found.
  ///    - The total number of heart rate variability records found.
  RecordCountResult calculateRecordCount(
      final Map<String, List<Map<String, dynamic>>> data) {
    var amountOfHR = 0; // Initialize counter for Heart Rate records.
    var amountOfHRV = 0; // Initialize counter for Heart Rate Variability records.

    // Iterate over each key-value pair in the input 'data' map.
    // 'key' is the string definition of the HealthKit metric type.
    // 'value' is the list of records (List<Map<String, dynamic>>) for that metric type.
    data.forEach((key, value) {
      // Check if the current key corresponds to the HealthKit Heart Rate metric type.
      if (key == HealthKitHealthMetric.heartRate.definition) {
        // If the key matches Heart Rate, iterate through the list of records ('value').
        // For each record ('element') in the list, increment the heart rate counter.
        // The content of 'element' is not inspected here; its presence signifies a record.
        for (final element in value) {
          amountOfHR += 1;
        }
      }

      // Check if the current key corresponds to the HealthKit Heart Rate Variability metric type.
      // Note: Using a separate 'if' statement. If HealthKit definitions were not unique
      // (which they are), an 'else if' might be preferred to prevent double counting.
      // Given unique definitions, separate 'if's are acceptable and clear.
      if (key == HealthKitHealthMetric.heartRateVariability.definition) {
        // If the key matches Heart Rate Variability, iterate through its list of records.
        // For each record, increment the HRV counter.
        for (final element in value) {
          amountOfHRV += 1;
        }
      }
      // Future Extension: To count records for other HealthKit metric types,
      // add more 'if' or 'else if' blocks here, similar to the ones above.
      // Example:
      // if (key == HealthKitHealthMetric.stepCount.definition) {
      //   for (final element in value) {
      //     amountOfStepCount += 1; // Assuming 'amountOfStepCount' variable is declared
      //   }
      // }
    });

    // After iterating through all entries in the data map,
    // return a RecordCountResult object populated with the final counts.
    return RecordCountResult(amountOfHR, amountOfHRV);
  }
}