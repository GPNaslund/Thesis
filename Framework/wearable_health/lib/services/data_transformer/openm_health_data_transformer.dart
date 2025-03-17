import 'package:wearable_health/services/data_transformer/health_data_transformer.dart';
import 'package:wearable_health/services/enums/health_data_format.dart';

class OpenMHealthDataTransformer implements HealthDataTransformer {
  @override
  final HealthDataFormat outputFormat;

  OpenMHealthDataTransformer(this.outputFormat);
}
