import 'package:wearable_health/provider/native/health_kit/data/health_kit_data_type.dart';
import 'package:wearable_health/provider/native/native_provider.dart';

class AppleHealthKit extends NativeProvider<HealthKitDataType> {
  AppleHealthKit(List<HealthKitDataType> dataList) {
    super.dataTypes = dataList;
  }
}