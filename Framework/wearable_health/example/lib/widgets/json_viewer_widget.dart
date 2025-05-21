import 'dart:convert';
import 'package:flutter/material.dart';

class JsonViewerWidget extends StatelessWidget {
  final dynamic jsonData;
  final String? title;

  const JsonViewerWidget({super.key, required this.jsonData, this.title});

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    String prettyString;
    try {
      prettyString = encoder.convert(jsonData);
    } catch (e) {
      prettyString = "Error encoding JSON: $e\n\nData: ${jsonData.toString()}";
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: PageStorage(
              bucket: PageStorageBucket(),
              child: SelectableText(
                prettyString,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
