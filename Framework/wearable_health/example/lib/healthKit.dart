import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/controller/wearable_health.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_data.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/service/health_kit/health_kit_interface.dart';

typedef HealthData = Map<String, String>;

void main() {
  runApp(const HealthKitApp());
}

class HealthKitApp extends StatefulWidget {
  const HealthKitApp({super.key});
  @override
  State<HealthKitApp> createState() => _MyAppState();
}

class _MyAppState extends State<HealthKitApp> {
  String _platformVersion = 'Unknown';
  String _consoleOutput = '';
  List<HealthKitHealthMetric> dataTypes = [
    HealthKitHealthMetric.heartRateVariability,
  ];

  HealthKit hk = WearableHealth().getAppleHealthKit();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlugin();
    });
  }

  Future<void> _initializePlugin() async {
    await initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      final platformVersion = await hk.getPlatformVersion();
      if (mounted) {
        setState(() {
          _platformVersion = platformVersion;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _consoleOutput += 'Could not get platform version: $e\n';
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    _appendToConsole('Requesting permissions...');
    try {
      final result = await hk.requestPermissions(dataTypes);
      if (mounted) {
        _appendToConsole('Permissions granted: $result');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException when requesting permissions: ${e.message}');
      if (mounted) {
        _appendToConsole('Error when requesting permissions: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error when requesting permissions: $e');
      if (mounted) {
        _appendToConsole('Error when requesting permissions: $e');
      }
    }
  }

  Future<void> _fetchData() async {
    _appendToConsole('Getting data...');

    try {
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      final startOfWeek = endOfDay.subtract(const Duration(days: 6));
      final midnightStartOfWeek = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      final range = DateTimeRange(start: midnightStartOfWeek, end: endOfDay);

      _appendToConsole('Calling get data with time interval:');
      _appendToConsole('Start: ${range.start.toIso8601String()}');
      _appendToConsole('End:  ${range.end.toIso8601String()}');

      final result = await hk.getData(dataTypes, range);

      if (mounted) {
        if (result.isEmpty) {
          _appendToConsole('No data was found for the period.');
        } else {
          _appendToConsole('Data amount received (${result.length}):');
          for (int i = 0; i < result.length; i++) {
            final dataPoint = result[i];
            final openMHealthData = dataPoint.toOpenMHealth();
            for (final element in openMHealthData) {
              _appendToConsole('${element.toJson()}');
            }
            if (i % 50 == 0) await Future.delayed(Duration.zero);
          }
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        _appendToConsole(
          'PlatformException when getting the data: ${e.message}\n${e.details}\n${e.stacktrace}',
        );
      }
    } catch (e, stacktrace) {
      if (mounted) {
        _appendToConsole('Error when getting data: $e\n$stacktrace');
      }
    }
  }

  void _appendToConsole(String text) {
    if (mounted) {
      setState(() {
        _consoleOutput =
            '${_consoleOutput.isEmpty ? '' : '$_consoleOutput\n'}$text';
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


  Future<void> _redirectToSettings() async {
    _appendToConsole('Redirecting to app settings for permissions...');
    try {
      final result = await hk.redirectToPermissionsSettings();
      if (mounted) {
        _appendToConsole('Settings redirection ${result ? 'successful' : 'failed'}');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException during settings redirection: ${e.message}');
      if (mounted) {
        _appendToConsole('Error during settings redirection: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error during settings redirection: $e');
      if (mounted) {
        _appendToConsole('Error during settings redirection: $e');
      }
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Wearable Health Exempel')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Running on: $_platformVersion'),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _requestPermissions,
                    child: const Text('Request permissions'),
                  ),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Get data (1 week)'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _redirectToSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text('Open permissions settings'),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Console:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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
                    // reverse: true,
                    child: Text(_consoleOutput),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _consoleOutput = ''),
                  child: const Text('Clear console'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
