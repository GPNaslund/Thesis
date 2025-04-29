import 'package:wearable_health/provider/native/health_connect/data/health_connect_data_type.dart';

class HealthConnectHeartRate implements HealthConnectDataType {
  @override
  String getDefinition() {
    return "heartRate";
  }
}
