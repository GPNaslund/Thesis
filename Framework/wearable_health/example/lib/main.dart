import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/provider/native/health_connect/data/health_connect_data_type.dart';
import 'package:wearable_health/provider/native/health_connect/data/heart_rate.dart';
import 'package:wearable_health/provider/native/health_connect/data/skin_temperature.dart';
import 'package:wearable_health/provider/native/health_kit/data/body_temperature.dart';
import 'package:wearable_health/provider/native/health_kit/data/health_kit_data_type.dart';
import 'package:wearable_health/provider/native/health_kit/data/heart_rate.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/wearable_health.dart';

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
  bool? _hasPermissions;
  Provider? _wearableHealthPlugin;
  String _consoleOutput = '';
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlugin();
    });
  }

  Future<void> _initializePlugin() async {
    if (Platform.isAndroid) {
      List<HealthConnectDataType> dataTypes = [
        HealthConnectHeartRate(),
        HealthConnectSkinTemperature()
      ];
      _wearableHealthPlugin = WearableHealth.getGoogleHealthConnect(dataTypes);
    } else if (Platform.isIOS) {
      List<HealthKitDataType> dataTypes = [
        HealthKitHeartRate(),
        HealthKitBodyTemperature()
      ];
      _wearableHealthPlugin = WearableHealth.getAppleHealthKit(dataTypes);
    } else {
      setState(() {
        _platformVersion = 'Unsupported Platform';
        _consoleOutput = 'Plugin only supports Android and iOS';
      });
      return;
    }

    await initPlatformState();
    await _checkPermissions();
  }


  Future<void> initPlatformState() async {
    if (_wearableHealthPlugin == null) return;
    try {
      final platformVersion = await _wearableHealthPlugin!.getPlatformVersion();
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
    if (_wearableHealthPlugin == null) return;
    _appendToConsole('Checking permissions...');
    try {
      final hasPermissions = await _wearableHealthPlugin!.hasPermissions();
      if (mounted) {
        setState(() {
          _hasPermissions = hasPermissions;
        });
        _appendToConsole('Got permissions: $hasPermissions');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException at permission check: ${e.message}');
      if (mounted) {
        _appendToConsole('Error when checking permissions: ${e.message}');
        setState(() {
          _hasPermissions = false;
        });
      }
    } catch (e) {
      debugPrint('Error when checking permissions: $e');
      if (mounted) {
        _appendToConsole('Error when checking permissions: $e');
        setState(() {
          _hasPermissions = false;
        });
      }
    }
  }


  Future<void> _requestPermissions() async {
    if (_wearableHealthPlugin == null) return;
    _appendToConsole('Requesting permissions...');
    try {
      final granted = await _wearableHealthPlugin!.requestPermissions();
      if (mounted) {
        setState(() {
          _hasPermissions = granted;
        });
        _appendToConsole('Permissions granted: $granted');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException when requesting permissions: ${e.message}');
      if (mounted) {
        _appendToConsole('Error when requesting permissions: ${e.message}');
        setState(() {
          _hasPermissions = false;
        });
      }
    } catch (e) {
      debugPrint('Error when requesting permissions: $e');
      if (mounted) {
        _appendToConsole('Error when requesting permissions: $e');
        setState(() {
          _hasPermissions = false;
        });
      }
    }
  }

  Future<void> _fetchData() async {
    if (_wearableHealthPlugin == null || _hasPermissions != true) {
      _appendToConsole('Plugin not initialized or permissions missing.');
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingData = true;
      });
    }
    _appendToConsole('Getting data...');

    try {
      final now = DateTime.now();
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      final startOfWeek = endOfDay.subtract(const Duration(days: 6));
      final midnightStartOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

      final range = DateTimeRange(start: midnightStartOfWeek, end: endOfDay);

      _appendToConsole('Calling get data with time interval:');
      _appendToConsole('Start: ${range.start.toIso8601String()}');
      _appendToConsole('End:  ${range.end.toIso8601String()}');


      final List<HealthData>? data = await _wearableHealthPlugin!.getData(range, null);

      if (mounted) {
        if (data == null || data.isEmpty) {
          _appendToConsole('No data was found for the period.');
        } else {
          _appendToConsole('Data amount received (${data.length}):');
          for (int i = 0; i < data.length; i++) {
            final dataPoint = data[i];
            _appendToConsole('${i + 1}. ${dataPoint.toString()}');
            if (i % 50 == 0) await Future.delayed(Duration.zero);
          }
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        _appendToConsole('PlatformException when getting the data: ${e.message}\n${e.details}\n${e.stacktrace}');
      }
    } catch (e, stacktrace) {
      if (mounted) {
        _appendToConsole('Error when getting data: $e\n$stacktrace');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _appendToConsole(String text) {
    if (mounted) {
      setState(() {
        _consoleOutput = '${_consoleOutput.isEmpty ? '' : '$_consoleOutput\n'}$text';
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
              Text('Permissions granted: ${_hasPermissions ?? 'Checking...'}'),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _wearableHealthPlugin == null ? null : _requestPermissions,
                    child: const Text('Request permissions'),
                  ),
                  ElevatedButton(
                    onPressed: (_hasPermissions == true && !_isLoadingData && _wearableHealthPlugin != null)
                        ? _fetchData
                        : null,
                    child: _isLoadingData
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Get data (1 week)'),
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