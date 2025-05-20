import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
import 'package:wearable_health_example/models/conversion_validity_result.dart';

class HKDataConversionValidation {
  HKDataFactory hkDataFactory;

  HKDataConversionValidation(this.hkDataFactory);

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

      if (key == HealthKitHealthMetric.heartRate.definition) {
        for (final element in value) {
          var isValid = isValidHKHeartRateConversion(element, hkDataFactory);
          amountHR += 1;
          if (isValid) {
            validConversionHR += 1;
          }
        }
      }

      if (key == HealthKitHealthMetric.heartRateVariability.definition) {
        for (final element in value) {
          var isValid = isValidHKHeartRateVariabilityConversion(element, hkDataFactory);
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