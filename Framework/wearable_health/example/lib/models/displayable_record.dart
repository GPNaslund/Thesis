class DisplayableRecord {
  final Map<String, dynamic> rawData;
  final Map<String, dynamic> convertedData;
  final List<Map<String, dynamic>> omhDataList;
  final int recordIndex;

  DisplayableRecord({
    required this.rawData,
    required this.convertedData,
    required this.omhDataList,
    required this.recordIndex,
  });
}