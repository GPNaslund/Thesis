
import 'package:flutter/material.dart';
import 'package:wearable_health_example/models/performance_test_result.dart';
import 'package:wearable_health_example/widgets/placeholder.dart';

class PerformanceModule extends StatelessWidget {
  final PerformanceTestResult? data;

  const PerformanceModule({super.key, required this.data });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return PlaceholderModule(
        message: 'Run an experiment to see performance metrics',
        icon: Icons.speed,
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed, size: 64, color: Colors.purple),
            const SizedBox(height: 16),
            Text(
              'Performance Module\nTotal time: ${data!.dataFetchExecutionInMs + data!.conversionExecutionInMs}ms',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching raw data took ${data!.dataFetchExecutionInMs}ms\nConversion to openMHealth took ${data!.conversionExecutionInMs}ms\nConverted ${data!.amountOfElementsConverted} objects',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}

class ConversionStats {
  int conversionTimeInMs;
  int amountOfElementsConverted;

  ConversionStats(this.conversionTimeInMs, this.amountOfElementsConverted);
}