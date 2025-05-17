import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/wearable_health_service.dart';
import '../../../constants/metrics.dart';
import '../../../constants/metrics_mapper.dart';
import '../../services/metric_filters/skin_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';

class DataDisplayPage extends StatefulWidget {
  final HealthMetric metric;

  const DataDisplayPage({super.key, required this.metric});

  @override
  State<DataDisplayPage> createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  final WearableHealthService _wearableHealthService = WearableHealthService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _useConverter = false;
  bool _isLoading = false;
  String _resultLabel = '';
  List<String> _fetchedResults = [];

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final fullDateTime = DateTime( // ✅ Use UTC for consistent filtering
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStart) {
        _startDate = fullDateTime;
      } else {
        _endDate = fullDateTime;
      }
    });
  }

  Future<void> _fetchData() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _resultLabel = 'Fetching data...';
    });

    final range = DateTimeRange(start: _startDate!, end: _endDate!);

    try {
      final data = await _wearableHealthService.getHealthData(
        widget.metric,
        range,
        convert: _useConverter,
      );

      if (!_useConverter && widget.metric == HealthMetric.skinTemperature) {
        debugPrint('Raw Skin Temperature Data:');
        for (var entry in data) {
          debugPrint(jsonEncode(entry));
        }
      }

      List<dynamic> filteredData;

      // ✅ Metric-specific filtering logic
      if (widget.metric == HealthMetric.skinTemperature) {
        if (_useConverter) {
          filteredData = filterOpenMHealthSkinTemperature(
            entries: data.cast<OpenMHealthBodyTemperature>(),
            range: range,
          );
        } else {
          filteredData = filterRawSkinTemperatureWithTrimmedDeltas(
            rawEntries: data,
            range: range,
          );
        }
      } else {
        filteredData = data;
      }

      setState(() {
        _fetchedResults = filteredData.map((e) {
          if (e is OpenMHealthBodyTemperature) {
            return const JsonEncoder.withIndent('  ').convert(e.toJson());
          } else {
            return const JsonEncoder.withIndent('  ').convert(e);
          }
        }).toList();
        _resultLabel = 'Fetched ${filteredData.length} entries';
      });
    } catch (e) {
      setState(() {
        _fetchedResults = ['Error: $e'];
        _resultLabel = 'Error occurred';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearConsole() {
    setState(() {
      _fetchedResults = [];
      _resultLabel = '';
    });
  }

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
            Expanded(
              child: Container(
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDateTime(isStart: true),
                    child: Text(
                      _startDate != null
                          ? '${_startDate!.toString().substring(0, 16)}'
                          : 'Select Start Time',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickDateTime(isStart: false),
                    child: Text(
                      _endDate != null
                          ? '${_endDate!.toString().substring(0, 16)}'
                          : 'Select End Time',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
