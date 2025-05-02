import 'package:wearable_health/provider/enums/health_data_type.dart';
import 'package:wearable_health/provider/enums/supported_platform.dart';
import 'package:wearable_health/provider/native/native_provider.dart';

class AppleHealthKit extends NativeProvider {
  @override
  bool isDataTypeSupported(HealthDataType type) {
    return type.supportedPlatforms.contains(SupportedPlatform.ios);
  }
  
}