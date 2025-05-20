import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';

import '../../models/conversion_validity_result.dart';
import 'hc_heart_rate_conversion_validation.dart';
import 'hc_heart_rate_variability_conversion_validation.dart';

class HCDataConversionValidation {
  HCDataFactory hcDataFactory;

  HCDataConversionValidation(this.hcDataFactory);

  ConversionValidityResult performConversionValidation(
      final Map<String, dynamic> data) {
    var amountHR = 0;
    var amountHRV = 0;
    var validConversionHR = 0;
    var validConversionHRV = 0;

    data.forEach((key, value) {
      if (value is! List<dynamic>) {
        print("value was not a List, got: ${value.runtimeType}");
      }
      if (key == HealthConnectHealthMetric.heartRate.definition) {
        for (final element in value) {
          var isValid = isValidHeartRateConversion(element, hcDataFactory);
          amountHR += 1;
          if (isValid) {
            validConversionHR += 1;
          }
        }
      }

      if (key == HealthConnectHealthMetric.heartRateVariability.definition) {
        for (final element in value) {
          var isValid = isValidHeartRateVariabilityConversion(
            element,
            hcDataFactory,
          );
          amountHRV += 1;
          if (isValid) {
            validConversionHRV += 1;
          }
        }
      }
    });

    return ConversionValidityResult(
      amountHR,
      validConversionHR,
      amountHRV,
      validConversionHRV,
    );
  }
}