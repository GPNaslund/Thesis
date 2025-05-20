import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../services/wearable_health_service.dart';
import '../../../constants/metrics.dart';
import '../../../constants/metrics_mapper.dart';
import '../../../services/metric_handlers/heart_rate_variability.dart';
import '../../../services/metric_handlers/heart_rate.dart';
import '../validation/validation_report_page.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate_variability.dart';
import '../../../services/metric_validators/open_m_health/heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/heart_rate.dart';
import '../../../services/metric_validators/open_m_health/heart_rate.dart';



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
  List<OpenMHealthHeartRateVariability> _parsedHRVOpenMHealth = [];
  List<OpenMHealthHeartRate> _parsedHeartRateOpenMHealth = [];

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

    final fullDateTime = DateTime(
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

      if (widget.metric == HealthMetric.heartRateVariability) {
        if (_useConverter) {
          _parsedHRVOpenMHealth = data.cast<OpenMHealthHeartRateVariability>();
        }
        _fetchedResults = handleHeartRateVariabilityData(
          data: data,
          range: range,
          useConverter: _useConverter,
          onStatusUpdate: (label) {
            setState(() {
              _resultLabel = label;
            });
          },
        );
        setState(() {});
        return;
      }

      if (widget.metric == HealthMetric.heartRate) {
        if (_useConverter) {
          _parsedHeartRateOpenMHealth = data.cast<OpenMHealthHeartRate>();
        }
        _fetchedResults = handleHeartRateData(
          data: data,
          range: range,
          useConverter: _useConverter,
          onStatusUpdate: (label) {
            setState(() {
              _resultLabel = label;
            });
          },
        );
        setState(() {});
        return;
      }

      setState(() {
        _fetchedResults = data.map((e) {
          return const JsonEncoder.withIndent('  ').convert(e);
        }).toList();
        _resultLabel = 'Fetched ${_fetchedResults.length} entries';
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
              child: ListView.separated(
                itemCount: _fetchedResults.length + (_fetchedResults.length > 1 ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  if (_fetchedResults.length > 1 && index == 0) {
                    final allJson = '[\n${_fetchedResults.join(',\n')}\n]';
                    return ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: const Text(
                        'All Records',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          padding: const EdgeInsets.all(12),
                          child: SelectableText(
                            allJson,
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                          ),
                        ),
                      ],
                    );
                  }

                  final actualIndex = _fetchedResults.length > 1 ? index - 1 : index;
                  final json = _fetchedResults[actualIndex];

                  return ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      'Record #${actualIndex + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.grey.shade100,
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          json,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                      ),
                      if (_useConverter) ...[
                        if (widget.metric == HealthMetric.heartRateVariability)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                            child: ElevatedButton(
                              onPressed: () {
                                final entry = _parsedHRVOpenMHealth[actualIndex];
                                final validator = HeartRateVariabilityValidator(
                                  expectedRange: (_startDate != null && _endDate != null)
                                      ? DateTimeRange(start: _startDate!, end: _endDate!)
                                      : null,
                                );
                                final result = validator.validate(entry);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ValidationReportPage(
                                      recordIndex: actualIndex,
                                      result: result,
                                      recordJson: entry.toJson(),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Run Validation'),
                            ),
                          ),
                        if (widget.metric == HealthMetric.heartRate)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                            child: ElevatedButton(
                              onPressed: () {
                                final entry = _parsedHeartRateOpenMHealth[actualIndex];
                                final validator = HeartRateValidator(
                                  expectedRange: (_startDate != null && _endDate != null)
                                      ? DateTimeRange(start: _startDate!, end: _endDate!)
                                      : null,
                                );
                                final result = validator.validate(entry);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ValidationReportPage(
                                      recordIndex: actualIndex,
                                      result: result,
                                      recordJson: entry.toJson(),
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Run Validation'),
                            ),
                          ),
                      ],
                    ],
                  );
                },
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
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchData,
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Text('Fetch Data'),
            ),
            ElevatedButton(
              onPressed: _clearConsole,
              child: const Text('Clear Console'),
            ),
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