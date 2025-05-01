import 'package:wearable_health/provider/health_data.dart';

class GetDataResponse {
  List<HealthData> result;

  GetDataResponse(this.result);

  factory GetDataResponse.fromMap(Map<String, dynamic> serialized) {
    _validateMapContent(serialized);
    return GetDataResponse(serialized["result"]);
  }

  static void _validateMapContent(Map<String, dynamic> content) {
    if (!content.containsKey("result")) {
      throw Exception("[GetDataResponse] serialized map lacks 'result' key");
    }

    if (content["result"] is! List<HealthData>) {
      throw Exception("[GetDataResponse] 'result' must be List<HealthData> / List<Map<String, dynamic>>");
    }
  }
}