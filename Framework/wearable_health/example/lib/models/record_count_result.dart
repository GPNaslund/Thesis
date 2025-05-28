/// A data model class used to store the aggregated counts of different types of health records,
/// specifically focusing on Heart Rate (HR) and Heart Rate Variability (HRV) records.
///
/// This class provides a simple way to summarize the volume of specific data types
/// found within a larger dataset.
class RecordCountResult {
  /// The total number of Heart Rate (HR) records counted.
  int amountOfHRRecords;

  /// The total number of Heart Rate Variability (HRV) records counted.
  int amountOfHRVRecords;

  /// Creates an instance of [RecordCountResult].
  ///
  /// Both parameters are required to represent the counts of HR and HRV records.
  ///
  /// Parameters:
  ///  - [amountOfHRRecords]: The total count of Heart Rate records.
  ///  - [amountOfHRVRecords]: The total count of Heart Rate Variability records.
  RecordCountResult(this.amountOfHRRecords, this.amountOfHRVRecords);

  /// Calculates the combined total number of HR and HRV records.
  ///
  /// Returns:
  ///  The sum of [amountOfHRVRecords] and [amountOfHRRecords].
  int get totalAmountOfRecords => amountOfHRVRecords + amountOfHRRecords;
}