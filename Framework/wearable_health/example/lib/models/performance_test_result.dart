class PerformanceTestResult {
  int dataFetchExecutionInMs;
  int conversionExecutionInMs;
  int amountOfElementsConverted;

  PerformanceTestResult(this.dataFetchExecutionInMs,  this.conversionExecutionInMs, this.amountOfElementsConverted);

  int get totalExecutionTimeMs => dataFetchExecutionInMs + conversionExecutionInMs;
}