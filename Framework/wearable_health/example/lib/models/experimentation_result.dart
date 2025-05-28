/// A data model class designed to encapsulate the comprehensive results of
/// a data processing and conversion experiment, typically involving health data.
///
/// This class aggregates various metrics, including:
///  - Counts of total records, heart rate (HR) records, and heart rate variability (HRV) records.
///  - Counts of successfully validated or converted HR and HRV records.
///  - Timing metrics for different stages of the experiment, such as total time,
///    raw data fetch time, and data conversion time.
///
/// It serves as a structured container for reporting the outcomes of performance
/// and validation tests.
class ExperimentationResult {
  /// The total number of records fetched or processed at the beginning of the experiment.
  /// This often represents the superset of all data before any specific filtering
  /// or categorization into HR/HRV occurs.
  int amountOfRecords;

  /// The total number of records identified specifically as Heart Rate (HR) data
  /// within the [amountOfRecords].
  int amountOfHRRecords;

  /// The number of Heart Rate (HR) records that successfully passed all
  /// validation and/or conversion steps in the experiment.
  int amountOfValidatedHR;

  /// The total number of records identified specifically as Heart Rate Variability (HRV) data
  /// within the [amountOfRecords].
  int amountOfHRVRecords;

  /// The number of Heart Rate Variability (HRV) records that successfully passed all
  /// validation and/or conversion steps in the experiment.
  int amountOfValidatedHRV;

  /// The total time taken for the entire experimentation process, measured in milliseconds.
  /// This typically includes data fetching, processing, validation, and conversion.
  int totalFetchTimeMs; // Consider renaming to totalExecutionTimeMs if it's more than just fetching

  /// The time specifically spent on fetching the raw data from its source,
  /// measured in milliseconds.
  int rawDataFetchTimeMs;

  /// The time specifically spent on converting the data from one format to another
  /// (e.g., from a platform-specific format to OpenMHealth), measured in milliseconds.
  /// This might also include validation time if it's part of the conversion pipeline.
  int conversionFetchTimeMs; // Consider renaming to conversionAndValidationTimeMs if validation is included here

  /// Creates an instance of [ExperimentationResult].
  ///
  /// All parameters are required to fully describe the outcome of the experiment.
  ///
  /// Parameters:
  ///  - [amountOfRecords]: Total records processed.
  ///  - [amountOfHRRecords]: Total heart rate records.
  ///  - [amountOfValidatedHR]: Successfully validated heart rate records.
  ///  - [amountOfHRVRecords]: Total heart rate variability records.
  ///  - [amountOfValidatedHRV]: Successfully validated heart rate variability records.
  ///  - [totalFetchTimeMs]: Total execution time for the experiment in milliseconds.
  ///  - [rawDataFetchTimeMs]: Time spent fetching raw data in milliseconds.
  ///  - [conversionFetchTimeMs]: Time spent on data conversion in milliseconds.
  ExperimentationResult({
    required this.amountOfRecords,
    required this.amountOfHRRecords,
    required this.amountOfValidatedHR,
    required this.amountOfHRVRecords,
    required this.amountOfValidatedHRV,
    required this.totalFetchTimeMs,
    required this.rawDataFetchTimeMs,
    required this.conversionFetchTimeMs,
  });
}