// lib/features/data_display/data_display_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/wearable_health_service.dart';
import '../../../constants/metrics.dart';
import '../../../constants/metrics_mapper.dart';

/// Page for displaying fetched health data for a selected metric
class DataDisplayPage extends StatefulWidget {

  final HealthMetric metric;

  const DataDisplayPage({super.key, required this.metric});

  @override
  State<DataDisplayPage> createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  final WearableHealthService _wearableHealthService = WearableHealthService();
  bool _isLoading = false;
  /// converter for knowing if converting data into Open MHealth format
  bool _useConverter = false;
  /// results to display in the UI
  List<String> _fetchedResults = [];
  /// label to display, what is being shown to the UI
  String _resultLabel = '';

  /// Fetches health data using the WearableHealthService
  Future<void> _fetchData() async {
    /// Show loading UI and clear old results
    setState(() {
      _isLoading = true;
      _fetchedResults = ['Fetching data...'];
    });

    try {
      /// Define a time range from now minus 1 day to now
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 1));
      final range = DateTimeRange(start: start, end: now);

      /// Request health data from the service using (health metric, date range, converted to open Mhealth or not)
      final healthData = await _wearableHealthService.getHealthData(
        widget.metric,
        range,
        convert: _useConverter,
      );

      /// label to show what data is being displayed
      final label = 'Showing ${getMetricLabel(widget.metric)} data in '
          '${_useConverter ? "OpenMHealth" : "Raw"} format:';

      /// If no data is returned, inform the user
      if (healthData.isEmpty) {
        setState(() {
          _resultLabel = label;
          _fetchedResults = [
            'No data fetched.',
            'Make sure ${getMetricLabel(widget.metric)} is allowed in settings.'
          ];
        });
      } else {
        /// Else convert each data entry to formatted JSON and display
        setState(() {
          _resultLabel = label;
          _fetchedResults = healthData.map((e) {
            try {
              final encoder = JsonEncoder.withIndent('  ');
              return encoder.convert(e is Map ? e : e.toJson());
            } catch (err) {
              return 'Error parsing item: $err';
            }
          }).toList();
        });
      }
    } catch (e) {
      /// Catch permission or data errors and display a custom message
      setState(() {
        _fetchedResults = ['There was an error when trying to fetch data. Make sure you have allowed permission for this metric in the app settings.'];
        _resultLabel = '';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Clears UI output area
  void _clearConsole() {
    setState(() {
      _fetchedResults = [];
      _resultLabel = '';
    });
  }

  /// Builds the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data for ${getMetricLabel(widget.metric)}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_resultLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _resultLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            /// Container box to display results
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
                  child: SelectableText(_fetchedResults.join('\n\n')),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Button to fetch data
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

            /// Button to clear console/output
            ElevatedButton(
              onPressed: _clearConsole,
              child: const Text('Clear Console'),
            ),
            const SizedBox(height: 12),

            /// Dropdown to toggle between Raw and OpenMHealth formats
            DropdownButton<bool>(
              isExpanded: true,
              value: _useConverter,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _useConverter = val;
                  });
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
