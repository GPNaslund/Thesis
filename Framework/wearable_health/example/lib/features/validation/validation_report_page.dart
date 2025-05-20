// lib/features/validation_validation_report_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/metric_validators/metric_validator.dart';

class ValidationReportPage extends StatelessWidget {
  final int recordIndex;
  final ValidationResult result;
  final Map<String, dynamic> recordJson;

  const ValidationReportPage({
    super.key,
    required this.recordIndex,
    required this.result,
    required this.recordJson,
  });

  @override
  Widget build(BuildContext context) {
    final problems = (result.details?['problems'] as List?)?.cast<String>() ?? [];
    final messages = (result.details?['messages'] as List?)?.cast<String>() ?? [];
    final details = Map<String, dynamic>.from(result.details ?? {});
    details.remove('problems');
    details.remove('messages');

    return Scaffold(
      appBar: AppBar(
        title: Text('Validation Report – Record #${recordIndex + 1}'),
      ),
      body: SingleChildScrollView(
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
            ...details.entries.expand((entry) {
              final section = entry.key;
              final sectionData = entry.value;

              if (sectionData is Map<String, dynamic>) {
                return [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 4),
                    child: Text('$section:', style: Theme.of(context).textTheme.titleSmall),
                  ),
                  ...sectionData.entries.map((check) {
                    final checkKey = check.key;
                    final checkVal = check.value;
                    final passed = !problems.contains(checkKey);
                    return _buildCheckTile(
                      title: checkKey,
                      result: passed,
                      detail: '$checkVal',
                    );
                  }),
                ];
              } else {
                final passed = !problems.contains(section);
                return [
                  _buildCheckTile(
                    title: section,
                    result: passed,
                    detail: sectionData.toString(),
                  )
                ];
              }
            }),
            if (messages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Issues:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...messages.map((msg) => Text('- $msg')),
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

  Widget _buildCheckTile({
    required String title,
    required bool result,
    required String detail,
  }) {
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
