import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';

import '../../models/conversion_validity_result.dart';
import 'hc_heart_rate_conversion_validation.dart';
import 'hc_heart_rate_variability_conversion_validation.dart';

/// A class responsible for validating the conversion of raw data maps
/// into Health Connect compatible data structures.
///
/// This class iterates through a map of health data, where keys represent
/// health metric types (e.g., heart rate, HRV) and values are lists of
/// individual data points for those metrics. It uses specific validation functions
/// for each metric type to determine if each data point can be successfully
/// converted into a corresponding Health Connect entity.
class HCDataConversionValidation {
  /// A factory instance used to create Health Connect data objects during validation.
  /// This allows the validation logic to attempt a conversion and check its success.
  HCDataFactory hcDataFactory;

  /// Creates an instance of [HCDataConversionValidation].
  ///
  /// Requires an [hcDataFactory] which will be used to attempt the creation
  /// of Health Connect data objects as part of the validation process.
  HCDataConversionValidation(this.hcDataFactory);

  /// Performs validation on a given map of health data to check how many
  /// entries can be successfully converted to Health Connect formats.
  ///
  /// The [data] map is expected to have keys corresponding to
  /// [HealthConnectHealthMetric.definition] strings and values as lists
  /// of dynamic objects, where each object represents a single data point
  /// for that metric.
  ///
  /// It counts the total number of heart rate (HR) and heart rate variability (HRV)
  /// data points and how many of them are valid for conversion.
  ///
  /// Returns a [ConversionValidityResult] summarizing the validation outcomes.
  ConversionValidityResult performConversionValidation(
      final Map<String, dynamic> data) {
    var amountHR = 0; // Total count of heart rate data points encountered.
    var amountHRV = 0; // Total count of heart rate variability data points encountered.
    var validConversionHR = 0; // Count of heart rate data points that passed conversion validation.
    var validConversionHRV = 0; // Count of heart rate variability data points that passed conversion validation.

    // Iterate through each entry (metric type and its list of data points) in the input map.
    data.forEach((key, value) {
      // Basic check to ensure the value associated with a metric key is a list.
      if (value is! List<dynamic>) {
        print(
            "[HCDataConversionValidation] Value for key '$key' was not a List, got: ${value
                .runtimeType}. Skipping validation for this key.");
        return; // Skip this entry if the value is not a list.
      }

      // Validate Heart Rate data points.
      if (key == HealthConnectHealthMetric.heartRate.definition) {
        for (final element in value) {
          // Attempt to validate the conversion of a single heart rate data point.
          var isValid = isValidHCHeartRateConversion(element, hcDataFactory);
          amountHR += 1;
          if (isValid) {
            validConversionHR += 1;
          }
        }
      }
      // Validate Heart Rate Variability data points.
      else if (key ==
          HealthConnectHealthMetric.heartRateVariability.definition) {
        for (final element in value) {
          // Attempt to validate the conversion of a single HRV data point.
          var isValid = isValidHCHeartRateVariabilityConversion(
            element,
            hcDataFactory,
          );
          amountHRV += 1;
          if (isValid) {
            validConversionHRV += 1;
          }
        }
      }
      // Future: Add handling for other HealthConnectHealthMetric types here.
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