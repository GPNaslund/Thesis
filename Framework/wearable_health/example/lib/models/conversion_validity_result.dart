/// A data model class that encapsulates the results of a conversion validation process,
/// specifically focusing on heart rate and heart rate variability data.
///
/// This class holds counts for:
///  - The total number of heart rate objects encountered.
///  - The number of heart rate objects that were correctly converted or validated.
///  - The total number of heart rate variability objects encountered.
///  - The number of heart rate variability objects that were correctly converted or validated.
///
/// It's used to summarize the outcome of validation procedures that check the integrity
/// and successful transformation of health data.
class ConversionValidityResult {
  /// The total number of heart rate data objects that were processed or
  /// attempted for conversion/validation.
  final int totalAmountOfHeartRateObjects;

  /// The number of heart rate data objects that were successfully
  /// converted and/or passed all validation checks.
  final int correctlyConvertedHeartRateObjects;

  /// The total number of heart rate variability (HRV) data objects
  /// that were processed or attempted for conversion/validation.
  final int totalAmountOfHeartRateVariabilityObjects;

  /// The number of heart rate variability (HRV) data objects that
  /// were successfully converted and/or passed all validation checks.
  final int correctlyConvertedHeartRateVariabilityObjects;

  /// Creates an instance of [ConversionValidityResult].
  ///
  /// All parameters are required and represent the summarized counts
  /// from a data conversion and validation process.
  ///
  /// Parameters:
  ///  - [totalAmountOfHeartRateObjects]: The total count of heart rate objects.
  ///  - [correctlyConvertedHeartRateObjects]: The count of successfully validated heart rate objects.
  ///  - [totalAmountOfHeartRateVariabilityObjects]: The total count of HRV objects.
  ///  - [correctlyConvertedHeartRateVariabilityObjects]: The count of successfully validated HRV objects.
  ConversionValidityResult(this.totalAmountOfHeartRateObjects,
      this.correctlyConvertedHeartRateObjects,
      this.totalAmountOfHeartRateVariabilityObjects,
      this.correctlyConvertedHeartRateVariabilityObjects,); // The trailing comma is idiomatic in Dart for multi-line parameter lists.
}