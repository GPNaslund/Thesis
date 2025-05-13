// lib/features/data_display/data_display_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/wearable_health_service.dart';
import '../../../constants/metrics.dart';

class DataDisplayPage extends StatefulWidget {
  final HealthMetric metric;

  const DataDisplayPage({super.key, required this.metric});

  @override
  State<DataDisplayPage> createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  final WearableHealthService _wearableHealthService = WearableHealthService();
  bool _isLoading = false;
  bool _useConverter = false;
  List<String> _fetchedResults = [];

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _fetchedResults = ['Fetching data...'];
    });

    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 1));
      final range = DateTimeRange(start: start, end: now);

      final healthData = await _wearableHealthService.getHealthData(
        widget.metric,
        range,
        convert: _useConverter,
      );

      if (healthData.isEmpty) {
        setState(() {
          _fetchedResults = [
            'No data fetched.',
            'Make sure ${widget.metric.name} is allowed in settings.'
          ];
        });
      } else {
        setState(() {
          _fetchedResults = healthData.map((e) {
            try {
              // if openMHealth
              if (_useConverter) {
                final encoder = JsonEncoder.withIndent('  ');
                return '${encoder.convert(e.toJson())}\n';
              }
              // else just get raw data
              return '${e.toString()}\n';
            } catch (err) {
              return 'Error parsing item: $err\n';
            }
          }).toList();
        });
      }
    } catch (e) {
      setState(() {
        _fetchedResults = ['Error while fetching data: $e'];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearConsole() {
    setState(() => _fetchedResults = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data for ${widget.metric.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Output:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey.shade100,
                ),
                child: SingleChildScrollView(
                  child: SelectableText(_fetchedResults.join('\n')),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchData,
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Fetch Data'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _clearConsole,
              child: const Text('Clear Console'),
            ),
            const SizedBox(height: 12),
            DropdownButton<bool>(
              isExpanded: true,
              value: _useConverter,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _useConverter = val);
                }
              },
              items: const [
                DropdownMenuItem(value: false, child: Text('Raw Format')),
                DropdownMenuItem(value: true, child: Text('OpenMHealth Format')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}