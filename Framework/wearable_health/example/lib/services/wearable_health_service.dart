// lib/services/wearable_health_service.dart

import 'dart:io';

import 'package:wearable_health/wearable_health.dart';
import 'package:wearable_health/provider/provider.dart';
import 'package:wearable_health/provider/provider_type.dart';

class WearableHealthService {
  late final Provider _provider;

  WearableHealthService() {
    if (Platform.isAndroid) {
      _provider = WearableHealth.getDataProvider(ProviderType.googleHealthConnect);
    } else {
      _provider = WearableHealth.getDataProvider(ProviderType.appleHealthKit);
    }
  }

  Future<String> getPlatformVersion() async {
    try {
      final version = await _provider.getPlatformVersion();
      return version;
    } catch (e) {
      return 'Failed to get platform version';
    }
  }

  Future<bool> hasStepsPermission() async {
    String permission;
    if (Platform.isAndroid) {
      permission = 'android.permission.health.READ_STEPS';
    } else {
      permission = 'HKQuantityTypeIdentifierStepCount';
    }

    try {
      return await _provider.hasPermissions(permissions: [permission]);
    } catch (e) {
      return false;
    }
  }

  Future<bool> requestStepsPermission() async {
    String permission;
    if (Platform.isAndroid) {
      permission = 'android.permission.health.READ_STEPS';
    } else {
      permission = 'HKQuantityTypeIdentifierStepCount';
    }

    try {
      return await _provider.requestPermissions(permissions: [permission]);
    } catch (e) {
      return false;
    }
  }
}
