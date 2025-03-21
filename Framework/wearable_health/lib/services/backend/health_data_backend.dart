import 'package:wearable_health/services/backend/http_health_data_backend.dart';

abstract class HealthDataBackend {
  factory HealthDataBackend.http({
    required String endpoint,
    Map<String, String>? authHeaders,
    int retryAttempts = 3,
  }) {
    return HttpHealthDataBackend(
      endpoint: endpoint,
      authHeaders: authHeaders,
      retryAttempts: retryAttempts,
    );
  }

  Future<bool> sendData(Map<String, dynamic> data);
}
