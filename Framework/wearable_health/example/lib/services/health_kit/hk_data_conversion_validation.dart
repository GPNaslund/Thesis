import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
import 'package:wearable_health_example/models/conversion_validity_result.dart';

import 'hk_heart_rate_validation.dart';
import 'hk_heart_rate_variability_validation.dart';

/// A class responsible for validating the conversion of raw data maps,
/// presumably sourced from Apple HealthKit, into structured data objects
/// using a provided [HKDataFactory].
///
/// This class iterates through a map of health data where keys represent
/// HealthKit metric types (e.g., heart rate, HRV based on their definitions)
/// and values are lists of individual data points for those metrics.
/// It uses specific validation functions (e.g., `isValidHKHeartRate`,
/// `isValidHKHeartRateVariability`) for each metric type to determine
/// if each data point can be successfully processed or converted by the factory.
class HKDataConversionValidation {
  /// A factory instance used to potentially create or process HealthKit
  /// data objects during the validation process. This allows the validation
  /// logic to simulate or attempt a conversion/processing step.
  HKDataFactory hkDataFactory;

  /// Creates an instance of [HKDataConversionValidation].
  ///
  /// Requires an [hkDataFactory] which will be passed to the specific
  /// validation functions (e.g., `isValidHKHeartRate`) to aid in their
  /// validation logic, possibly by attempting to instantiate objects.
  HKDataConversionValidation(this.hkDataFactory);

  /// Performs validation on a given map of health data to check how many
  /// entries can be successfully processed or are considered valid for conversion
  /// according to HealthKit-specific validation rules.
  ///
  /// The input [data] map is expected to have:
  ///  - Keys that are strings corresponding to [HealthKitHealthMetric.definition]
  ///    (e.g., "HKQuantityTypeIdentifierHeartRate").
  ///  - Values that are `List<Map<String, dynamic>>`, where each inner map
  ///    represents a single raw data point for that HealthKit metric type.
  ///
  /// It counts the total number of heart rate (HR) and heart rate variability (HRV)
  /// data points encountered and how many of them pass their respective validation checks.
  ///
  /// Returns a [ConversionValidityResult] summarizing the validation outcomes for HR and HRV.
  ConversionValidityResult performConversionValidation(
      // Note: The original type was `Map<String, List<Map<String, dynamic>>> data`.
      // If the 'value' in `data.forEach((key, value)` can be something other than
      // `List<Map<String, dynamic>>` for certain keys, the type might need to be
      // more general like `Map<String, dynamic>` for the input, and then type checking
      // would be done internally. Assuming `List<Map<String, dynamic>>` is intended for relevant keys.
      final Map<String, List<Map<String, dynamic>>> data,) {
    var amountHR = 0; // Total count of heart rate data points encountered.
    var amountHRV = 0; // Total count of heart rate variability data points encountered.
    var validConversionHR = 0; // Count of heart rate data points that passed validation.
    var validConversionHRV = 0; // Count of heart rate variability data points that passed validation.

    // Iterate through each entry (metric type definition string and its list of raw data points) in the input map.
    data.forEach((key, value) {
      // Validate Heart Rate data points if the key matches the HR definition.
      if (key == HealthKitHealthMetric.heartRate.definition) {
        // Iterate over each raw heart rate data point in the list.
        for (final element in value) {
          // Call the specific validation function for HealthKit heart rate data.
          // This function likely uses the hkDataFactory to attempt some form of processing or object creation.
          var isValid = isValidHKHeartRate(
              element,
              // A Map<String, dynamic> representing a single HR data point
              hkDataFactory
          );
          amountHR += 1; // Increment total HR count.
          if (isValid) {
            validConversionHR +=
            1; // Increment valid HR count if validation passed.
          }
        }
      }
      // Validate Heart Rate Variability data points if the key matches the HRV definition.
      // Using separate 'if' statements. If a key could match multiple definitions (unlikely for HealthKit type identifiers),
      // 'else if' might be preferred. Given distinct type identifiers, this is acceptable.
      if (key == HealthKitHealthMetric.heartRateVariability.definition) {
        // Iterate over each raw HRV data point in the list.
        for (final element in value) {
          // Call the specific validation function for HealthKit HRV data.
          var isValid = isValidHKHeartRateVariability(
            element,
            // A Map<String, dynamic> representing a single HRV data point
            hkDataFactory,
          );
          amountHRV += 1; // Increment total HRV count.
          if (isValid) {
            validConversionHRV +=
            1; // Increment valid HRV count if validation passed.
          }
        }
      }
    });

    // Return the aggregated results of the validation.
    return ConversionValidityResult(
      amountHR,
      validConversionHR,
      amountHRV,
      validConversionHRV,
    );
  }
}