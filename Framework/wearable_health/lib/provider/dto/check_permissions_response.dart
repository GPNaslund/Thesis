import '../enums/health_data_type.dart';

class CheckPermissionsResponse {
  List<HealthDataType> permissions;

  CheckPermissionsResponse(this.permissions);

  factory CheckPermissionsResponse.fromMap(Map<Object?, Object?> rawResponse) {
    Map<String, dynamic> serialized = Map.from(rawResponse);

    _validateMapContent(serialized);
    List<String> providedPermissions = List.from(serialized["permissions"]);
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

    if (content["permissions"] is! List<Object?>) {
      throw Exception("[CheckPermissionsResponse] 'permissions' must be List<String>. Received: ${content["permissions"].runtimeType}");
    }

    for (final element in content["permissions"]) {
      if (element is! String) {
        throw Exception("[CheckPermissionsResponse] found non string in 'permissions' List");
      }
    }
  }

}