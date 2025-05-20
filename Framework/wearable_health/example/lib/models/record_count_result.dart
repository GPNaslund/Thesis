class RecordCountResult {
  int amountOfHRRecords;
  int amountOfHRVRecords;

  RecordCountResult(this.amountOfHRRecords, this.amountOfHRVRecords);

  int get totalAmountOfRecords => amountOfHRVRecords + amountOfHRRecords;
}