import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health_example/hc_heart_rate_conversion_validation.dart';
import 'package:wearable_health_example/placeholder.dart';

class ConversionModule extends StatelessWidget {
  final Map<String, dynamic>? data;
  final HCDataFactory hcDataFactory;

  const ConversionModule({
    super.key,
    required this.data,
    required this.hcDataFactory,
  });

  ConversionValidityResults performConversionValidation() {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return PlaceholderModule(
        message: 'Run an experiment to see conversion accuracy results',
        icon: Icons.transform,
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.transform, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Conversion Module\nAccuracy: ${(data!['accuracyRate'] * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder for the full Conversion Module widget\nthat would be implemented in a separate file.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}

class ConversionValidityResults {
  int totalAmountOfHeartRateObjects;
  int correctlyConvertedHeartRateObjects;
  int totalAmountOfHeartRateVariabilityObjects;
  int correctlyConvertedHeartRateVariabilityObjects;

  ConversionValidityResults(
    this.totalAmountOfHeartRateObjects,
    this.correctlyConvertedHeartRateObjects,
    this.totalAmountOfHeartRateVariabilityObjects,
    this.correctlyConvertedHeartRateVariabilityObjects,
  );
}
