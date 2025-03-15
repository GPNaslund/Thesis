import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';
import 'package:wearable_health/services/providers/health_provider.dart';

class HealthConnectProvider implements HealthProvider {
  late AuthConfig _authConfig;
  late List<HealthDataType> _scopes;

  HealthConnectProvider(AuthConfig authConfig, List<HealthDataType> scopes) {
    _authConfig = authConfig;
    _scopes = scopes;
  }

  @override
  AuthConfig get authConfig => _authConfig;

  @override
  List<HealthDataType> get scopes => _scopes;
}
