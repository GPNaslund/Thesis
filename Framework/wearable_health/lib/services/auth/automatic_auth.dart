import 'package:wearable_health/services/auth/auth_config.dart';

class AutomaticAuth implements AuthConfig {
  AutomaticAuth();

  @override
  String getUsername() {
    return "";
  }

  @override
  String getToken() {
    return "";
  }
}
