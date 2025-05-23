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
  bool _isLiveSeedingActive = false; // New: To track live seeding state
  bool _isProcessingLiveSeedAction = false; // New: To disable button during async call

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

  Future<void> _toggleLiveSeeding() async {
    if (_hasPermissions != true) {
      _appendToConsole('Cannot start/stop live seeding: Permissions missing.');
      return;
    }

    setState(() {
      _isProcessingLiveSeedAction = true; // Disable button during the call
    });

    if (_isLiveSeedingActive) {
      // Try to stop live seeding
      _appendToConsole('Attempting to stop live data seeding...');
      try {
        final bool success = await _dataSeederPlugin.stopSeedDataLive();
        if (mounted) {
          if (success) {
            _appendToConsole('Stop live data seeding command successful.');
            setState(() {
              _isLiveSeedingActive = false;
            });
          } else {
            _appendToConsole('Stop live data seeding command failed (plugin returned false).');
            // Consider if _isLiveSeedingActive should be reverted or reflect assumed state
          }
        }
      } on PlatformException catch (e) {
        if (mounted) {
          _appendToConsole(
            'PlatformException during stop live data seeding: ${e.message}\n${e.details}',
          );
        }
      } catch (e, stacktrace) {
        if (mounted) {
          _appendToConsole('Error during stop live data seeding: $e\n$stacktrace');
        }
      }
    } else {
      // Try to start live seeding
      _appendToConsole('Attempting to start live data seeding...');
      try {
        final bool success = await _dataSeederPlugin.seedDataLive();
        if (mounted) {
          if (success) {
            _appendToConsole('Start live data seeding command successful.');
            setState(() {
              _isLiveSeedingActive = true;
            });
          } else {
            _appendToConsole('Start live data seeding command failed (plugin returned false).');
          }
        }
      } on PlatformException catch (e) {
        if (mounted) {
          _appendToConsole(
            'PlatformException during start live data seeding: ${e.message}\n${e.details}',
          );
        }
      } catch (e, stacktrace) {
        if (mounted) {
          _appendToConsole('Error during start live data seeding: $e\n$stacktrace');
        }
      }
    }

    if (mounted) {
      setState(() {
        _isProcessingLiveSeedAction = false; // Re-enable button
      });
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
                    onPressed: (_hasPermissions == true && !_isSeedingData && !_isProcessingLiveSeedAction)
                        ? _seedDataAction // Existing one-off seed
                        : null,
                    child: _isSeedingData
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white, // Assuming button text is white
                      ),
                    )
                        : const Text('Seed Batch Data'), // Clarified button text
                  ),
                ],
              ),
              const SizedBox(height: 10), // Space before new button
              Center( // Center the new button
                child: ElevatedButton(
                  onPressed: (_hasPermissions == true && !_isProcessingLiveSeedAction)
                      ? _toggleLiveSeeding
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLiveSeedingActive ? Colors.redAccent : Colors.green,
                  ),
                  child: _isProcessingLiveSeedAction // Show progress indicator if processing
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isLiveSeedingActive ? 'Stop Live Seeding' : 'Start Live Seeding',
                    style: const TextStyle(color: Colors.white), // Ensure text is visible
                  ),
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
                    child: Text(_consoleOutput),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    if (mounted) { // Good practice to check mounted before setState
                      setState(() => _consoleOutput = '');
                    }
                  },
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
