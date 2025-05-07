import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/source/healthConnect/data/health_connect_data.dart';
import 'package:wearable_health/source/healthConnect/hc_health_metric.dart';
import 'package:wearable_health/source/health_data_source.dart';
import 'package:wearable_health/wearable_health.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_data.dart';

typedef HealthData = Map<String, String>;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _consoleOutput = '';
  List<HealthConnectHealthMetric> dataTypes = [
    HealthConnectHealthMetric.skinTemperature,
  ];
  HealthDataSource hc = WearableHealth.getGoogleHealthConnect();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlugin();
    });
  }

  Future<void> _initializePlugin() async {
    await initPlatformState();
    await _checkPermissions();
  }

  Future<void> initPlatformState() async {
    try {
      final platformVersion = await hc.getPlatformVersion();
      if (mounted) {
        setState(() {
          _platformVersion = platformVersion ?? 'Unknown';
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

  Future<void> _checkPermissions() async {
    _appendToConsole('Checking permissions...');
    try {
      final result = await hc.checkPermissions();
      if (mounted) {
        _appendToConsole('Got permissions: ${result.toString()}');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException at permission check: ${e.message}');
      if (mounted) {
        _appendToConsole('Error when checking permissions: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error when checking permissions: $e');
      if (mounted) {
        _appendToConsole('Error when checking permissions: $e');
      }
    }
  }

  Future<void> _requestPermissions() async {
    _appendToConsole('Requesting permissions...');
    try {
      final result = await hc.requestPermissions(dataTypes);
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

      final result = await hc.getData(dataTypes, range);

      if (mounted) {
        if (result.isEmpty) {
          _appendToConsole('No data was found for the period.');
        } else {
          _appendToConsole('Data amount received (${result.length}):');
          final healthConnectData = result as List<HealthConnectData>;
          for (int i = 0; i < result.length; i++) {
            final dataPoint = healthConnectData[i];
            final openMHealthData = dataPoint.toOpenMHealth();
            for (int y = 0; y < openMHealthData.length; y++) {
              _appendToConsole('${i + 1}:${y + 1}. ${openMHealthData[y].toJson()}');
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
                    color: Colors.grey.shade100, // Ljus bakgrund för konsolen
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController, // Använd scroll controller
                    // reverse: true, // Ta bort reverse för att se output i kronologisk ordning
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
