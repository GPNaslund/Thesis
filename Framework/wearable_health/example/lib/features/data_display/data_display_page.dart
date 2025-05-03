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
  bool _useConverter = false; // not used yet
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
          _fetchedResults = healthData.map((e) => e.toString()).toList();
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
          children: [
            Row(
              children: [
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
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _clearConsole,
                  child: const Text('Clear Console'),
                ),
                const SizedBox(width: 12),
                DropdownButton<bool>(
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
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Output:', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ],
        ),
      ),
    );
  }
}
