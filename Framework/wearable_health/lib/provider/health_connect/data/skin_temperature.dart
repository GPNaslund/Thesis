import 'package:wearable_health/provider/health_connect/data/health_connect_data_type.dart';

class SkinTemperature implements HealthConnectDataType {
  @override
  String getDefinition() {
    return "android.permission.health.READ_SKIN_TEMPERATURE";
  }
}
