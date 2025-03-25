import 'package:flutter/material.dart';
import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';
import 'package:wearable_health/services/providers/health_provider.dart';

class HealthConnectProvider implements HealthProvider {
  late AuthConfig _authConfig;
  late List<HealthDataType> _scopes;
  late WidgetBuilder? _privacyPolicy;

  HealthConnectProvider(AuthConfig authConfig, List<HealthDataType> scopes, WidgetBuilder? widgetBuilder) {
    _authConfig = authConfig;
    _scopes = scopes;
    _privacyPolicy = widgetBuilder;
  }

  @override
  AuthConfig get authConfig => _authConfig;

  @override
  List<HealthDataType> get scopes => _scopes;

  WidgetBuilder? get privacyPolicy => _privacyPolicy;
}
