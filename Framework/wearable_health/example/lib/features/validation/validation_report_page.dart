import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/metric_validators/metric_validator.dart';

class ValidationReportPage extends StatelessWidget {
  final int recordIndex;
  final ValidationResult result;
  final Map<String, dynamic> recordJson; // Make it generic

  const ValidationReportPage({
    super.key,
    required this.recordIndex,
    required this.result,
    required this.recordJson,
  });

  @override
  Widget build(BuildContext context) {
    final problems = result.details?['problems'] as List? ?? [];
    final details = Map<String, dynamic>.from(result.details ?? {});
    details.remove('problems'); // Exclude 'problems' from checks

    return Scaffold(
      appBar: AppBar(
        title: Text('Validation Report – Record #${recordIndex + 1}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.summary,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: result.isValid ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text('Record Preview:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            _buildPreviewCard(),
            const SizedBox(height: 16),
            Text('Checks:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...details.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;
              final passed = !problems.any((p) => p.toString().toLowerCase().contains(key.toLowerCase()));

              return _buildCheckTile(
                title: key,
                result: passed,
                detail: (value is bool) ? '' : '$value',
              );
            }),
            if (problems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Issues:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...problems.map((p) => Text('- $p')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final jsonString = const JsonEncoder.withIndent('  ').convert(recordJson);
    return Card(
      color: Colors.grey.shade100,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          jsonString,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildCheckTile({required String title, required bool result, required String detail}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(result ? Icons.check_circle : Icons.cancel,
            color: result ? Colors.green : Colors.red, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text('$title: $detail')),
      ],
    );
  }
}
