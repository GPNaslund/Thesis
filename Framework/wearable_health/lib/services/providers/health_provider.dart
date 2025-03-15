import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';

abstract class HealthProvider {
  final List<HealthDataType> scopes;
  final AuthConfig authConfig;

  HealthProvider({required this.scopes, required this.authConfig});
}
