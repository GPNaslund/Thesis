class ExperimentationResult {
  int amountOfRecords;
  int amountOfHRRecords;
  int amountOfValidatedHR;
  int amountOfHRVRecords;
  int amountOfValidatedHRV;
  int totalFetchTimeMs;
  int rawDataFetchTimeMs;
  int conversionFetchTimeMs;

  ExperimentationResult({
    required this.amountOfRecords,
    required this.amountOfHRRecords,
    required this.amountOfValidatedHR,
    required this.amountOfHRVRecords,
    required this.amountOfValidatedHRV,
    required this.totalFetchTimeMs,
    required this.rawDataFetchTimeMs,
    required this.conversionFetchTimeMs
  });
}
