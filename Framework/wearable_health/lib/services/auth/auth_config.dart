import 'package:wearable_health/services/auth/automatic_auth.dart';

abstract class AuthConfig {
  factory AuthConfig.automaticAuth() {
    return AutomaticAuth();
  }

  String getUsername();
  String getToken();
}
