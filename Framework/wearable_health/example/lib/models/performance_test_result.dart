/// A data model class used to store the results of a performance test,
/// specifically focusing on the time taken for data fetching and data conversion,
/// as well as the quantity of data processed.
///
/// This class helps in evaluating the efficiency of data transformation pipelines.
class PerformanceTestResult {
  /// The time taken to fetch the initial dataset, measured in milliseconds.
  /// This duration typically represents the I/O operation to retrieve data
  /// before any conversion or processing begins.
  int dataFetchExecutionInMs;

  /// The time taken to perform the core data conversion operations,
  /// measured in milliseconds. This duration captures the processing time
  /// required to transform the data from one format or structure to another.
  int conversionExecutionInMs;

  /// The total number of individual elements or records that were successfully
  /// converted during the performance test.
  int amountOfElementsConverted;

  /// Creates an instance of [PerformanceTestResult].
  ///
  /// All parameters are required to accurately represent the outcome
  /// of the performance test.
  ///
  /// Parameters:
  ///  - [dataFetchExecutionInMs]: Time in milliseconds for data fetching.
  ///  - [conversionExecutionInMs]: Time in milliseconds for data conversion.
  ///  - [amountOfElementsConverted]: The count of elements converted.
  PerformanceTestResult(this.dataFetchExecutionInMs,
      this.conversionExecutionInMs,
      this.amountOfElementsConverted,); // Trailing comma is idiomatic in Dart for multi-line parameter lists.

  /// Calculates the total execution time for the entire process measured by this result.
  ///
  /// This is the sum of the time taken for data fetching and the time taken for
  /// data conversion.
  ///
  /// Returns:
  ///  The total execution time in milliseconds.
  int get totalExecutionTimeMs =>
      dataFetchExecutionInMs + conversionExecutionInMs;
}