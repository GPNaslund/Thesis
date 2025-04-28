import 'package:wearable_health/provider/native/health_kit/data/health_kit_data_type.dart';

class HealthKitHeartRate implements HealthKitDataType {
  @override
  String getDefinition() {
    return "heartRate";
  }
}
