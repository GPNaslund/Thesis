import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wearable_health_example/placeholder.dart';

class ConversionModule extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ConversionModule({
    super.key,
    required this.data,
  });

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
            const Icon(
              Icons.transform,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Conversion Module\nAccuracy: ${(data!['accuracyRate'] * 100)
                  .toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder for the full Conversion Module widget\nthat would be implemented in a separate file.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}