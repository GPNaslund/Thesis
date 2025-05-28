import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health_example/models/record_count_result.dart';

/// A utility class responsible for counting the number of records
/// for specific health metrics within a given dataset.
///
/// This class processes a map where keys represent health metric types
/// (e.g., heart rate, heart rate variability) and values are lists of
/// individual data points for those metrics. It then tallies the number
/// of records found for each supported metric type.
class HCRecordCount {
  /// Calculates the total number of Heart Rate (HR) and Heart Rate Variability (HRV)
  /// records present in the provided [data] map.
  ///
  /// The [data] map is expected to have:
  ///  - Keys that are strings corresponding to [HealthConnectHealthMetric.definition]
  ///    (e.g., "HeartRate" or "HeartRateVariabilityRmssd").
  ///  - Values that are `List<Map<String, dynamic>>`, where each inner map
  ///    represents a single data record for that metric type.
  ///
  /// The method iterates through the data, identifies records matching HR and HRV
  /// metric definitions, and counts them.
  ///
  /// Returns a [RecordCountResult] object containing the total counts
  /// for heart rate and heart rate variability records.
  RecordCountResult calculateRecordCount(
      final Map<String, List<Map<String, dynamic>>> data) {
    var amountOfHR = 0; // Counter for Heart Rate records.
    var amountOfHRV = 0; // Counter for Heart Rate Variability records.

    // Iterate over each entry (metric type definition string and its list of records) in the input data map.
    data.forEach((key, value) {
      // Check if the current key matches the definition for Heart Rate.
      if (key == HealthConnectHealthMetric.heartRate.definition) {
        // If it's Heart Rate data, iterate through the list of records
        // and increment the HR counter for each record.
        // The 'element' variable itself is not used beyond confirming its existence in the list.
        for (final element in value) {
          amountOfHR += 1;
        }
      }
      // Check if the current key matches the definition for Heart Rate Variability.
      // Note: This uses 'if' and not 'else if'. If a key could theoretically match both
      // (which shouldn't happen with unique HealthConnectHealthMetric definitions),
      // it would be counted for both. Using 'else if' would be safer if there was
      // any ambiguity, but with distinct definitions, 'if' is acceptable.
      if (key == HealthConnectHealthMetric.heartRateVariability.definition) {
        // If it's Heart Rate Variability data, iterate through the list of records
        // and increment the HRV counter for each record.
        for (final element in value) {
          amountOfHRV += 1;
        }
      }
      // Future: To count other metric types, add more 'if' or 'else if' blocks here:
      // if (key == HealthConnectHealthMetric.someOtherMetric.definition) {
      //   for (final element in value) {
      //     amountOfSomeOtherMetric += 1;
      //   }
      // }
    });

    // Return the result object containing the final counts.
    return RecordCountResult(amountOfHR, amountOfHRV);
  }
}