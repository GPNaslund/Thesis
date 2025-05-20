import 'package:flutter/material.dart';
import 'package:wearable_health_example/models/record_count_result.dart';
import 'package:wearable_health_example/services/health_connect/hc_record_count.dart';
import 'package:wearable_health_example/widgets/placeholder.dart';

class DataRetrievalModule extends StatelessWidget {

  final RecordCountResult? data;

  const DataRetrievalModule({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return PlaceholderModule(
        message: 'Run an experiment to see data retrieval results',
        icon: Icons.storage,
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storage, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Data Retrieval Module\n${data!.totalAmountOfRecords}records retrieved',
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
