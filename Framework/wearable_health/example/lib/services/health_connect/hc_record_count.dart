import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health_example/models/record_count_result.dart';

class HCRecordCount {
  RecordCountResult calculateRecordCount(final Map<String, List<Map<String, dynamic>>> data) {
    var amountOfHR = 0;
    var amountOfHRV = 0;

    data.forEach((key, value) {
      if (key == HealthConnectHealthMetric.heartRate.definition) {
        for (final element in value) {
          amountOfHR += 1;
        }
      }
      if (key == HealthConnectHealthMetric.heartRateVariability.definition) {
        for (final element in value) {
          amountOfHRV += 1;
        }
      }
    });

    return RecordCountResult(amountOfHR, amountOfHRV);
  }
}