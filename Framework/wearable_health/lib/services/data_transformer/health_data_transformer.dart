import 'package:wearable_health/services/data_transformer/openm_health_data_transformer.dart';
import 'package:wearable_health/services/enums/health_data_format.dart';

abstract class HealthDataTransformer {
  factory HealthDataTransformer.openMHealth() {
    return OpenMHealthDataTransformer(HealthDataFormat.openMHealth);
  }

  HealthDataFormat get outputFormat;
}
