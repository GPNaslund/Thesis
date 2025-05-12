abstract class JsonConverter {
  Map<dynamic, dynamic> extractMap(dynamic value, String errMsg);

  Map<String, dynamic> extractJsonObject(
    Map<dynamic, dynamic> data,
    String errMsg,
  );

  Map<String, List<Map<String, dynamic>>>
  extractJsonObjectWithListOfJsonObjects(dynamic value, String errMsg);

  List<dynamic> extractList(dynamic value, String errMsg);

  List<Map<String, dynamic>> extractListOfJsonObjects(
    dynamic value,
    String errMsg,
  );

  String extractStringValue(dynamic value, String errMsg);

  int extractIntValue(dynamic value, String errMsg);

  double extractDoubleValue(dynamic value, String errMsg);

  DateTime extractDateTime(dynamic value, String errMsg);

  DateTime extractDateTimeFromEpochMs(dynamic value, String errMsg);
}
