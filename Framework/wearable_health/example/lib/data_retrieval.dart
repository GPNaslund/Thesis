import 'package:flutter/material.dart';
import 'package:wearable_health_example/placeholder.dart';

class DataRetrievalModule extends StatelessWidget {
  final Map<String, dynamic>? data;

  const DataRetrievalModule({
    super.key,
    required this.data,
  });

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
            const Icon(
              Icons.storage,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Data Retrieval Module\n${data!['recordCount']} records retrieved',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder for the full Data Retrieval Module widget\nthat would be implemented in a separate file.',
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
