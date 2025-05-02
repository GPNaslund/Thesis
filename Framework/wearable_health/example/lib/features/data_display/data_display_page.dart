// lib/features/data_display/data_display_page.dart

import 'package:flutter/material.dart';
import '../../../services/wearable_health_service.dart';

class DataDisplayPage extends StatefulWidget {
  const DataDisplayPage({super.key});

  @override
  State<DataDisplayPage> createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  final WearableHealthService _wearableHealthService = WearableHealthService();
  final ScrollController _scrollController = ScrollController();

  String _consoleOutput = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _appendToConsole(String text) {
    setState(() {
      _consoleOutput =
      '${_consoleOutput.isEmpty ? '' : '$_consoleOutput\n'}$text';
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    _appendToConsole('Fetching health data...');

    try {
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      final startOfWeek = endOfDay.subtract(const Duration(days: 6));
      final range = DateTimeRange(start: startOfWeek, end: endOfDay);

      final healthData = await _wearableHealthService.getHealthData(range);

      if (healthData.isEmpty) {
        _appendToConsole('No data found for the selected time range.');
      } else {
        _appendToConsole('Data points received (${healthData.length}):');
        for (int i = 0; i < healthData.length; i++) {
          final dataPoint = healthData[i];
          _appendToConsole('${i + 1}. ${dataPoint.toString()}');
          if (i % 50 == 0) {
            await Future.delayed(Duration.zero); // To keep UI responsive
          }
        }
      }
    } catch (e) {
      _appendToConsole('Error while fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearConsole() {
    setState(() {
      _consoleOutput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Data Display')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                ElevatedButton(
                  onPressed: _clearConsole,
                  child: const Text('Clear Console'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Console:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                  color: Colors.grey.shade100,
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(_consoleOutput),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
