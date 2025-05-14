/// Defines interface for safely converting dynamic JSON data to typed Dart objects.
/// Each method performs validation and throws FormatException when input is invalid.
abstract class JsonConverter {
  /// Extracts a Map from dynamic value, validating its type.
  Map<dynamic, dynamic> extractMap(dynamic value, String errMsg);

  /// Converts a Map with dynamic keys to a Map with String keys.
  Map<String, dynamic> extractJsonObject(
    Map<dynamic, dynamic> data,
    String errMsg,
  );

  /// Extracts a nested structure: a Map with String keys and values as Lists of JSON objects.
  Map<String, List<Map<String, dynamic>>>
  extractJsonObjectWithListOfJsonObjects(dynamic value, String errMsg);

  /// Extracts a List from dynamic value, validating its type.
  List<dynamic> extractList(dynamic value, String errMsg);

  /// Extracts a List of JSON objects (Map<String, dynamic>) from dynamic value.
  List<Map<String, dynamic>> extractListOfJsonObjects(
    dynamic value,
    String errMsg,
  );

  /// Extracts a String from dynamic value, validating its type.
  String extractStringValue(dynamic value, String errMsg);

  /// Extracts an int from dynamic value, validating its type.
  int extractIntValue(dynamic value, String errMsg);

  /// Extracts a double from dynamic value, validating its type.
  double extractDoubleValue(dynamic value, String errMsg);

  /// Converts a String to DateTime, validating input format.
  DateTime extractDateTime(dynamic value, String errMsg);

  /// Creates a DateTime from epoch milliseconds.
  DateTime extractDateTimeFromEpochMs(dynamic value, String errMsg);
}
