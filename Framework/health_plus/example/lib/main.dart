import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_plus/health_plus.dart';
import 'package:health_plus/provider/apple_health_kit.dart';
import 'package:health_plus/provider/google_health_connect.dart';
import 'package:health_plus/provider/health_provider.dart';
import 'package:health_plus/provider/health_provider_type.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/ieee_1752_schema.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/physical_activity.dart';
import 'package:health_plus/schemas/mobile_health_schema/mobile_health_schema.dart';
import 'package:health_plus/schemas/mobile_health_schema/open_m_health_schema/heart_rate.dart';
import 'package:health_plus/schemas/mobile_health_schema/open_m_health_schema/open_m_health_schema.dart';
import 'package:health_plus/services/default_mobile_health_schema_converter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Plus Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HealthPlusScreen(),
    );
  }
}

class HealthPlusScreen extends StatefulWidget {
  const HealthPlusScreen({super.key});

  @override
  State<HealthPlusScreen> createState() => _HealthPlusScreenState();
}

class _HealthPlusScreenState extends State<HealthPlusScreen> {
  String _platformVersion = 'Unknown';
  String _status = 'Not initialized';
  final _healthPlusPlugin = HealthPlus();
  late HealthProvider _healthProvider;
  bool _isInitialized = false;
  List<HealthDataPoint> _healthData = [];
  List<MobileHealthSchema> _mobileHealthData = [];
  bool _isLoading = false;
  bool _showRawData =
      true; // Toggle between raw and mobile health schema format

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      try {
        platformVersion =
            await _healthPlusPlugin.getPlatformVersion() ??
            'Unknown platform version';
      } catch (e) {
        platformVersion = 'Unknown platform version';
        print('Failed to get platform version: $e');
      }

      final types = [HealthDataType.STEPS, HealthDataType.HEART_RATE];

      setState(() {
        _status = 'Creating health provider...';
      });

      final schemaConverter = DefaultMobileHealthSchemaConverter();

      try {
        if (Platform.isIOS) {
          _healthProvider = _healthPlusPlugin.getHealthProvider(
            HealthProviderType.appleHealthKit,
            types,
            schemaConverter,
          );
          setState(() {
            _status = 'Created Apple HealthKit provider';
          });
        } else if (Platform.isAndroid) {
          _healthProvider = _healthPlusPlugin.getHealthProvider(
            HealthProviderType.googleHealthConnect,
            types,
            schemaConverter,
          );
          setState(() {
            _status = 'Created Google Health Connect provider';
          });
        } else {
          setState(() {
            _status = 'Unsupported platform';
          });
          return;
        }
      } catch (e) {
        setState(() {
          _status = 'Error creating provider: $e';
        });
        return;
      }

      setState(() {
        _status = 'Initializing provider...';
      });

      try {
        if (_healthProvider is AppleHealthKit) {
          await (_healthProvider as AppleHealthKit).initialize();
        } else if (_healthProvider is GoogleHealthConnect) {
          await (_healthProvider as GoogleHealthConnect).initialize();
        }

        _isInitialized = true;
        setState(() {
          _status = 'Health provider initialized successfully';
        });
      } catch (e) {
        setState(() {
          _status = 'Error initializing provider: $e';
        });
      }
    } catch (e) {
      platformVersion = 'Unknown';
      setState(() {
        _status = 'Error in setup: $e';
      });
      print('Setup error: $e');
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> checkPermissions() async {
    if (!_isInitialized) {
      setState(() {
        _status = 'Health provider not initialized';
      });
      return;
    }

    try {
      final hasPermissions = await _healthProvider.checkPermissions();
      setState(() {
        _status = 'Has permissions: ${hasPermissions ?? false}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking permissions: $e';
      });
    }
  }

  Future<void> requestPermissions() async {
    if (!_isInitialized) {
      setState(() {
        _status = 'Health provider not initialized';
      });
      return;
    }

    setState(() {
      _status = 'Requesting permissions...';
    });

    try {
      final granted = await _healthProvider.requestPermissions();
      setState(() {
        _status = 'Permissions ${granted ? "granted" : "denied"}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error requesting permissions: $e';
      });
    }
  }

  Future<void> getRawData() async {
    if (!_isInitialized) {
      setState(() {
        _status = 'Health provider not initialized';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Fetching raw health data...';
      _showRawData = true;
    });

    try {
      _healthData = await _healthProvider.getData();
      setState(() {
        _status = 'Retrieved ${_healthData.length} raw health data points';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error retrieving raw health data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> getMobileHealthData() async {
    if (!_isInitialized) {
      setState(() {
        _status = 'Health provider not initialized';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Fetching data in Mobile Health Schema format...';
      _showRawData = false;
    });

    try {
      _mobileHealthData =
          await _healthProvider.getDataInMobileHealthSchemaFormat();
      setState(() {
        _status =
            'Retrieved ${_mobileHealthData.length} Mobile Health Schema data points';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error retrieving Mobile Health Schema data: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDataValue(HealthDataPoint point) {
    if (point.value is NumericHealthValue) {
      return '${(point.value as NumericHealthValue).numericValue.toStringAsFixed(2)} ${point.unit.name}';
    } else {
      return point.value.toString();
    }
  }

  String _formatMobileHealthValue(MobileHealthSchema schema) {
    if (schema is PhysicalActivity) {
      return schema.baseMovementQuantity != null
          ? '${schema.baseMovementQuantity!.value} ${schema.baseMovementQuantity!.unit}'
          : schema.activityName;
    } else if (schema is HeartRate) {
      return '${schema.heartRate.value} ${schema.heartRate.unit}';
    } else {
      return 'Schema: ${schema.schemaId}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Plus Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Platform: $_platformVersion',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Status: $_status',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: checkPermissions,
                    child: const Text('Check Permissions'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: requestPermissions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Request Permissions'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : getRawData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading && _showRawData
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Get Raw Data'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : getMobileHealthData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading && !_showRawData
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text('Get Mobile Health Data'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _showRawData ? 'Raw Health Data:' : 'Mobile Health Schema Data:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _showRawData
                      ? _buildRawDataList()
                      : _buildMobileHealthDataList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataList() {
    return _healthData.isEmpty
        ? const Center(child: Text('No raw health data available'))
        : Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            itemCount: _healthData.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = _healthData[index];
              return ListTile(
                title: Text(data.type.name),
                subtitle: Text(
                  'Date: ${data.dateFrom.toString().substring(0, 16)}',
                ),
                trailing: Text(
                  _formatDataValue(data),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        );
  }

  // Helper to format JSON for display
  String _prettyPrintJson(Map<String, dynamic> json) {
    String result = '';
    json.forEach((key, value) {
      if (value is Map) {
        result += '$key: {\n';
        (value as Map).forEach((k, v) {
          result += '  $k: $v\n';
        });
        result += '}\n';
      } else {
        result += '$key: $value\n';
      }
    });
    return result;
  }

  Widget _buildMobileHealthDataList() {
    return _mobileHealthData.isEmpty
        ? const Center(child: Text('No Mobile Health Schema data available'))
        : Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            itemCount: _mobileHealthData.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final schema = _mobileHealthData[index];

              // Display differently based on schema type
              String title = 'Unknown';
              if (schema is PhysicalActivity) {
                title = schema.activityName;
              } else if (schema is HeartRate) {
                title = 'Heart Rate';
              } else {
                title = schema.schemaId.split(':').last;
              }

              return ListTile(
                title: Text(title),
                subtitle: Text(
                  schema is OpenMHealthSchema
                      ? 'Open mHealth: ${schema.schemaId}'
                      : schema is Ieee1752Schema
                      ? 'IEEE 1752.1: ${schema.schemaId.split('/').last}'
                      : 'Schema: ${schema.schemaId}',
                ),
                trailing: Text(
                  _formatMobileHealthValue(schema),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  // Show dialog with full JSON representation when tapped
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Schema Details: $title'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Standard: ${schema is OpenMHealthSchema
                                      ? "Open mHealth"
                                      : schema is Ieee1752Schema
                                      ? "IEEE 1752.1"
                                      : "Unknown"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('Schema ID: ${schema.schemaId}'),
                                const SizedBox(height: 16),
                                const Text(
                                  'JSON Representation:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _prettyPrintJson(schema.toJson()),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                  );
                },
              );
            },
          ),
        );
  }
}
