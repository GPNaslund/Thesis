import 'dart:async';
import 'dart:io';

import 'package:data_seeder/data_seeder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
  final DataSeeder _dataSeederPlugin = DataSeeder();
  String _consoleOutput = '';
  bool _isSeedingData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePlugin();
    });
  }

  Future<void> _initializePlugin() async {
    _appendToConsole('Initializing DataSeeder plugin...');
    await _initPlatformState();
    await _checkPermissions();
    _appendToConsole('Plugin initialization complete.');
  }

  Future<void> _initPlatformState() async {
    try {
      final platformVersion = await _dataSeederPlugin.getPlatformVersion();
      if (mounted) {
        setState(() {
          _platformVersion = platformVersion ?? 'Unknown';
        });
        _appendToConsole('Platform Version: $_platformVersion');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _platformVersion = 'Failed to get platform version.';
        });
        _appendToConsole('Could not get platform version: $e');
      }
    }
  }

  Future<void> _checkPermissions() async {
    _appendToConsole('Checking permissions...');
    try {
      final hasPermissions = await _dataSeederPlugin.hasPermissions();
      if (mounted) {
        setState(() {
          _hasPermissions = hasPermissions;
        });
        _appendToConsole('Has permissions: $hasPermissions');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException at permission check: ${e.message}');
      if (mounted) {
        _appendToConsole('Error checking permissions: ${e.message}');
        setState(() {
          _hasPermissions = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      if (mounted) {
        _appendToConsole('Error checking permissions: $e');
        setState(() {
          _hasPermissions = false;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    _appendToConsole('Requesting permissions...');
    try {
      final granted = await _dataSeederPlugin.requestPermissions();
      if (mounted) {
        setState(() {
          _hasPermissions = granted;
        });
        _appendToConsole('Permissions granted: $granted');
      }
    } on PlatformException catch (e) {
      debugPrint('PlatformException requesting permissions: ${e.message}');
      if (mounted) {
        _appendToConsole('Error requesting permissions: ${e.message}');
        setState(() {
          _hasPermissions = false;
        });
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      if (mounted) {
        _appendToConsole('Error requesting permissions: $e');
        setState(() {
          _hasPermissions = false;
        });
      }
    }
  }

  Future<void> _seedDataAction() async {
    if (_hasPermissions != true) {
      _appendToConsole('Cannot seed data: Permissions missing.');
      return;
    }

    if (mounted) {
      setState(() {
        _isSeedingData = true;
      });
    }
    _appendToConsole('Attempting to seed data...');

    try {
      final bool success = await _dataSeederPlugin.seedData();

      if (mounted) {
        if (success) {
          _appendToConsole('Data seeding successful.');
        } else {
          _appendToConsole('Data seeding failed (plugin returned false).');
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        _appendToConsole(
          'PlatformException during data seeding: ${e.message}\n${e.details}\n${e.stacktrace}',
        );
      }
    } catch (e, stacktrace) {
      if (mounted) {
        _appendToConsole('Error during data seeding: $e\n$stacktrace');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSeedingData = false;
        });
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
        appBar: AppBar(title: const Text('Data Seeder Example')),
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
                    onPressed: _requestPermissions,
                    child: const Text('Request permissions'),
                  ),
                  ElevatedButton(
                    onPressed:
                        (_hasPermissions == true && !_isSeedingData)
                            ? _seedDataAction
                            : null,
                    child:
                        _isSeedingData
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Seed Data'),
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
                    color: Colors.grey.shade100,
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
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
