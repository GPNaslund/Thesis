import 'package:flutter/cupertino.dart';
import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';
import 'package:wearable_health/services/providers/health_provider.dart';

class AppleHealthProvider implements HealthProvider {
  late AuthConfig _authConfig;
  late List<HealthDataType> _scopes;
  late WidgetBuilder? _privacyPolicy;

  AppleHealthProvider(AuthConfig authConfig, List<HealthDataType> scopes, WidgetBuilder? privacyPolicy) {
    _authConfig = authConfig;
    _scopes = scopes;
    _privacyPolicy = privacyPolicy;
  }

  @override
  AuthConfig get authConfig => _authConfig;

  @override
  List<HealthDataType> get scopes => _scopes;

  @override
  WidgetBuilder? get privacyPolicy => _privacyPolicy;
}
