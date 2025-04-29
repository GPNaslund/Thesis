import 'package:wearable_health/provider/native/health_data_type.dart';

abstract class HealthKitDataType implements HealthDataType {
  @override
  String getDefinition();
}
