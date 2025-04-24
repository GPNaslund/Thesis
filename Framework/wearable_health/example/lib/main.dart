import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/provider/provider_type.dart';
import 'package:wearable_health/wearable_health.dart';

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
  late Provider _wearableHealthPlugin;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Wearable Health Plugin Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              if (_hasPermissions != null)
                Text('Permissions granted: $_hasPermissions'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkAndRequestPermissions,
                child: const Text('Request Steps Permission'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    try {
      final platformVersion = await _wearableHealthPlugin.getPlatformVersion();
      setState(() {
        _platformVersion = platformVersion ?? 'Unknown';
      });
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      _wearableHealthPlugin = WearableHealth.getDataProvider(
        ProviderType.googleHealthConnect,
      );
    } else {
      _wearableHealthPlugin = WearableHealth.getDataProvider(
        ProviderType.appleHealthKit,
      );
    }

    initPlatformState();
  }

  Future<void> _checkAndRequestPermissions() async {
    const stepsPermission = 'android.permission.health.READ_STEPS';
    try {
      final hasPermissions = await _wearableHealthPlugin.hasPermissions(
        permissions: [stepsPermission],
      );
      setState(() => _hasPermissions = hasPermissions);

      final granted = await _wearableHealthPlugin.requestPermissions(
        permissions: [stepsPermission],
      );
      setState(() => _hasPermissions = granted);
    } on PlatformException catch (e) {
      debugPrint('PlatformException: ${e.message}');
    }
  }
}
