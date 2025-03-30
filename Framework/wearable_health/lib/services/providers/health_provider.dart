import 'package:flutter/cupertino.dart';
import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';

abstract class HealthProvider {
  final List<HealthDataType> scopes;
  final AuthConfig authConfig;
  final WidgetBuilder? privacyPolicy;

  HealthProvider({required this.scopes, required this.authConfig, this.privacyPolicy});

  
}
