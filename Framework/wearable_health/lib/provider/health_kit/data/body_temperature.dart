import 'package:wearable_health/provider/health_kit/data/health_kit_data_type.dart';

class HealthKitBodyTemperature implements HealthKitDataType {
  @override
  String getDefinition() {
    return "HKQuantityTypeIdentifierBodyTemperature";
  }
}
