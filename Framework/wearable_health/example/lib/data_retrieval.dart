import 'package:flutter/material.dart';
import 'package:wearable_health_example/placeholder.dart';

class DataRetrievalModule extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>>? data;

  const DataRetrievalModule({super.key, required this.data});

  int calculateRecordCount() {
    var totalAmount = 0;
    data!.forEach((key, value) {
      totalAmount += value.length;
    });
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return PlaceholderModule(
        message: 'Run an experiment to see data retrieval results',
        icon: Icons.storage,
      );
    } else {
      final totalCount = calculateRecordCount();
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storage, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Data Retrieval Module\n$totalCount records retrieved',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }
  }
}
