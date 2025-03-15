import 'package:wearable_health/services/backend/health_data_backend.dart';

class HttpHealthDataBackend implements HealthDataBackend {
  final String endpoint;
  final Map<String, String>? authHeaders;
  final int retryAttempts;

  HttpHealthDataBackend({
    required this.endpoint,
    this.authHeaders,
    this.retryAttempts = 3,
  });

  @override
  Future<bool> sendData(Map<String, dynamic> data) async {
    return true;
  }
}
