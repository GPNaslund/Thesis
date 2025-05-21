import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_heart_rate_variability.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
import 'package:wearable_health_example/models/performance_test_result.dart';

class HKPerformanceTest {
  final HKDataFactory hkDataFactory;

  HKPerformanceTest(this.hkDataFactory);

  PerformanceTestResult getPerformanceResults(Map<String, dynamic> data, int dataFetchInMs, Stopwatch stopWatch) {
    var amountConverted = 0;
    stopWatch.reset();
    data.forEach((key, value) {
      if (value is! List<dynamic>) {
        log("Invalid value type");
      }

      if (key == HealthKitHealthMetric.heartRate.definition) {
        value.forEach((element) {
          var obj = hkDataFactory.createHeartRate(element);
          stopWatch.start();
          obj.toOpenMHealthHeartRate();
          stopWatch.stop();
          amountConverted += 1;
        });
      }

      if (key == HealthKitHealthMetric.heartRateVariability.definition) {
        value.forEach((element) {
          var obj = hkDataFactory.createHeartRateVariability(element);
          stopWatch.start();
          obj.toOpenMHealthHeartRateVariability();
          stopWatch.stop();
          amountConverted += 1;
        });
      }
    });
    return PerformanceTestResult(dataFetchInMs, stopWatch.elapsedMilliseconds, amountConverted);
  }
}