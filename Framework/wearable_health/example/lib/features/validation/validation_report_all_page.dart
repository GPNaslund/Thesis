// lib/features/validation_validation_report_all_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/metric_validators/metric_validator.dart';

class ValidationReportAllPage extends StatelessWidget {
  final List<ValidationResult> results;
  final Map<String, dynamic> recordJson;

  const ValidationReportAllPage({
    super.key,
    required this.results,
    required this.recordJson,
  });

  @override
  Widget build(BuildContext context) {
    final passed = results.where((r) => r.isValid).length;
    final failed = results.length - passed;

    final allProblems = <String>{};
    final allMessages = <String>[];
    final detailSections = <String, dynamic>{};

    for (var i = 0; i < results.length; i++) {
      final r = results[i];
      final prefix = 'Record #${i + 1}';

      final localProblems = (r.details?['problems'] as List?)?.cast<String>() ?? [];
      final localMessages = (r.details?['messages'] as List?)?.cast<String>() ?? [];

      allProblems.addAll(localProblems);
      allMessages.addAll(localMessages);

      for (var key in r.details?.keys ?? []) {
        if (key == 'problems' || key == 'messages') continue;
        detailSections['$prefix – $key'] = r.details?[key];
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Validation Summary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Validation Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Total records tested:', results.length),
            _buildSummaryRow('Records passed:', passed, color: Colors.green),
            _buildSummaryRow('Records failed:', failed, color: Colors.red),
            const SizedBox(height: 20),

            if (detailSections.isNotEmpty)
              Text('Validation Details:', style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 8),
            ...detailSections.entries.map((entry) => _buildDetail(entry.key, entry.value)),

            if (allMessages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Issues:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              ...allMessages.map((msg) => Text('- $msg')),
            ],

            const SizedBox(height: 16),
            Text('Raw Data:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            _buildJsonPreview(recordJson),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(String title, dynamic data) {
    if (data is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ...data.entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  e.value == true || (e.value is! bool && e.value != null)
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 18,
                  color: e.value == true || (e.value is! bool && e.value != null)
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text('${e.key}: ${e.value}')),
              ],
            ),
          )),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.info, size: 18),
          const SizedBox(width: 6),
          Expanded(child: Text('$title: $data')),
        ],
      ),
    );
  }

  Widget _buildJsonPreview(Map<String, dynamic> json) {
    final formatted = const JsonEncoder.withIndent('  ').convert(json);
    return Card(
      color: Colors.grey.shade100,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SelectableText(
          formatted,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
        ),
      ),
    );
  }
}
