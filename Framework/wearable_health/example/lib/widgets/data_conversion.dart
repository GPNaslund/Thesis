import 'package:flutter/material.dart';
import 'package:wearable_health_example/widgets/placeholder.dart';

import '../models/conversion_validity_result.dart';

class ConversionModule extends StatelessWidget {
  final ConversionValidityResult? stats;

  const ConversionModule({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {

    if (stats == null) {
      return PlaceholderModule(
        message: 'Run an experiment to see conversion accuracy results',
        icon: Icons.transform,
      );
    } else {
      var totalAmountOfRecords =
          stats!.totalAmountOfHeartRateObjects +
          stats!.totalAmountOfHeartRateVariabilityObjects;
      var totalValidated =
          stats!.correctlyConvertedHeartRateObjects +
          stats!.correctlyConvertedHeartRateVariabilityObjects;
      var accuracyPercentage = totalValidated / totalAmountOfRecords * 100;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.transform, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Conversion Module\nAccuracy: ${accuracyPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Got ${stats!.totalAmountOfHeartRateObjects} amount of heart rate records.\n${stats!.correctlyConvertedHeartRateObjects} got validated.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Got ${stats!.totalAmountOfHeartRateVariabilityObjects} amount of heart rate variability records.\n${stats!.correctlyConvertedHeartRateVariabilityObjects} got validated.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}