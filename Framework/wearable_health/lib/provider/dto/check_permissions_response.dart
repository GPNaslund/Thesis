import '../enums/health_data_type.dart';

class CheckPermissionsResponse {
  List<HealthDataType> permissions;

  CheckPermissionsResponse(this.permissions);

  factory CheckPermissionsResponse.fromMap(Map<String, dynamic> serialized) {
    _validateMapContent(serialized);
    List<String> providedPermissions = serialized["permissions"];
    List<HealthDataType> result = [];
    for (final dataType in providedPermissions) {
      result.add(HealthDataType.fromString(dataType));
    }
    return CheckPermissionsResponse(result);
  }

  static void _validateMapContent(Map<String, dynamic> content) {
    if (!content.containsKey("permissions")) {
      throw Exception("[CheckPermissionsResponse] serialized map lacks 'permissions' key");
    }

    if (content["permissions"] is! List<String>) {
      throw Exception("[CheckPermissionsResponse] 'permissions' must be List<String>");
    }
  }

}