
import '../enums/health_data_type.dart';

class CheckPermissionsRequest {
  List<HealthDataType> dataTypes;

  CheckPermissionsRequest(this.dataTypes);

  Map<String, dynamic> toMap() {
    List<String> dataTypesString = [];
    for (final dataType in dataTypes) {
      dataTypesString.add(dataType.value);
    }

    return {
      "dataTypes": dataTypesString,
    };

  }
}