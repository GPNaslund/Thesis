import 'package:wearable_health/provider/native/health_connect/data/health_connect_data_type.dart';
import 'package:wearable_health/provider/native/native_provider.dart';

class GoogleHealthConnect extends NativeProvider<HealthConnectDataType> {
  GoogleHealthConnect(List<HealthConnectDataType> dataTypes) {
    super.dataTypes = dataTypes;
  }
}