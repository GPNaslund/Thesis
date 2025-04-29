// lib/services/wearable_health_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wearable_health/wearable_health.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/provider/native/health_connect/data/heart_rate.dart';
import 'package:wearable_health/provider/native/health_kit/data/heart_rate.dart';
import 'package:wearable_health/provider/native/health_connect/data/skin_temperature.dart';
import 'package:wearable_health/provider/native/health_kit/data/body_temperature.dart';

typedef HealthData = Map<String, String>;

class WearableHealthService {
  late final Provider _provider;

  WearableHealthService() {
    if (Platform.isAndroid) {
      _provider = WearableHealth.getGoogleHealthConnect([
        HealthConnectHeartRate(),
        HealthConnectSkinTemperature()
      ]);
    } else if (Platform.isIOS) {
      _provider = WearableHealth.getAppleHealthKit([
        HealthKitHeartRate(),
        HealthKitBodyTemperature()
      ]);
    } else {
      throw UnsupportedError("Platform not supported");
    }
  }

  Future<String> getPlatformVersion() async {
    try {
      return await _provider.getPlatformVersion();
    } catch (e) {
      return 'Failed to get platform version';
    }
  }

  Future<bool> hasPermissions() async {
    try {
      return await _provider.hasPermissions();
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      return await _provider.requestPermissions();
    } catch (e) {
      return false;
    }
  }

  Future<List<HealthData>> getHealthData(DateTimeRange range) async {
    try {
      return await _provider.getData(range, null);
    } catch (e) {
      return [];
    }
  }
}
