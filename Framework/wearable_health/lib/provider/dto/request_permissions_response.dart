import '../enums/health_data_type.dart';

class RequestPermissionsResponse {
  List<HealthDataType> permissions;

  RequestPermissionsResponse(this.permissions);

  factory RequestPermissionsResponse.fromMap(Map<String, dynamic> serialized) {
    _validateMapContent(serialized);
    List<HealthDataType> result = [];
    for (final dataType in serialized["permissions"]) {
      result.add(HealthDataType.fromString(dataType));
    }
    return RequestPermissionsResponse(result);
  }

  static void _validateMapContent(Map<String, dynamic> content) {
    if (!content.containsKey("permissions")) {
      throw Exception("[RequestPermissionsResponse] map lacks 'permissions' key");
    }

    if (content["permissions"] is! List<String>) {
      throw Exception("[RequestPermissionsResponse] 'permissions' must be List<String>");
    }
  }
}