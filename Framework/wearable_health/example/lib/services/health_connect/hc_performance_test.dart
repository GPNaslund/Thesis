import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health_example/models/performance_test_result.dart';

class HCPerformanceTest {
  final HCDataFactory hcDataFactory;

  HCPerformanceTest(this.hcDataFactory);


  PerformanceTestResult getPerformanceResults(Map<String, dynamic> data, int dataFetchInMs, Stopwatch stopWatch) {
    var amountConverted = 0;
    stopWatch.reset();
    data.forEach((key, value) {
      if (value is! List<dynamic>) {
        log("Invalid value type");
      }
      if (key == HealthConnectHealthMetric.heartRate.definition) {
        value.forEach((element) {
          var obj = hcDataFactory.createHeartRate(element);
          stopWatch.start();
          obj.toOpenMHealthHeartRate();
          stopWatch.stop();
          amountConverted += 1;
        });
      }
      if (key == HealthConnectHealthMetric.heartRateVariability.definition) {
        value.forEach((element) {
          var obj = hcDataFactory.createHeartRateVariability(element);
          stopWatch.start();
          obj.toOpenMHealthHeartRateVariabilityRmssd();
          stopWatch.stop();
          amountConverted += 1;
        });
      }
    });

    return PerformanceTestResult(dataFetchInMs, stopWatch.elapsedMilliseconds, amountConverted);
  }

}