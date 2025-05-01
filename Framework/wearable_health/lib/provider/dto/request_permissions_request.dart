import '../enums/health_data_type.dart';

class RequestPermissionsRequest {
  List<HealthDataType> dataTypes;

  RequestPermissionsRequest(this.dataTypes);

  Map<String, dynamic> toMap() {
    List<String> dataTypeStrings = [];
    for (final dataType in dataTypes) {
      dataTypeStrings.add(dataType.value);
    }
    return {
      "dataTypes": dataTypeStrings,
    };
  }
}