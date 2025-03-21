import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:wearable_health/services/providers/apple_health_provider.dart';
import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';
import 'package:wearable_health/services/providers/health_connect_provider.dart';
import 'package:wearable_health/services/backend/health_data_backend.dart';
import 'package:wearable_health/services/data_transformer/health_data_transformer.dart';
import 'package:wearable_health/services/providers/health_provider.dart';
import 'package:wearable_health/services/synchronization/sync_config.dart';
import 'package:wearable_health/wearable_health_data_constants.dart';

enum SyncStatus { idle, collecting, transforming, sending, completed, error, stopping, stopped }

typedef ErrorHandler = void Function(dynamic error);

class WearableHealth {
  final HealthProvider provider;
  final HealthDataTransformer transformer;
  final HealthDataBackend backend;
  final SyncConfig syncConfig;
  final ErrorHandler errorHandler;
  final List<HealthDataType> scope;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get statusStream => _statusController.stream;
  final MethodChannel _channel = MethodChannel(
    WearableHealthDataConstants.channelName,
  );

  WearableHealth._({
    required this.provider,
    required this.transformer,
    required this.backend,
    required this.syncConfig,
    required this.errorHandler,
    required this.scope,
  });

  static WearableHealth forHealthConnect(
    AuthConfig authConfig,
    List<HealthDataType> scope,
    HealthDataTransformer transformer,
    HealthDataBackend backend,
    SyncConfig syncConfig,
    ErrorHandler errorHandler,
  ) {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Health Connect is only available on Android");
    }

    return WearableHealth._(
      provider: HealthConnectProvider(authConfig, scope),
      transformer: transformer,
      backend: backend,
      syncConfig: syncConfig,
      errorHandler: errorHandler,
      scope: scope,
    );
  }

  static WearableHealth forAppleHealth(
    AuthConfig authConfig,
    List<HealthDataType> scope,
    HealthDataTransformer transformer,
    HealthDataBackend backend,
    SyncConfig syncConfig,
    ErrorHandler errorHandler,
  ) {
    if (!Platform.isIOS) {
      throw UnsupportedError("AppleHealth is only available for IOS");
    }

    return WearableHealth._(
      provider: AppleHealthProvider(authConfig, scope),
      transformer: transformer,
      backend: backend,
      syncConfig: syncConfig,
      errorHandler: errorHandler,
      scope: scope,
    );
  }

  Future<String?> getPlatformVersion() async {
    return await _channel.invokeMethod(
      WearableHealthDataConstants.methodGetPlatformVersion,
      {},
    );
  }

  Future<bool> requestPermissions() async {
    try {
      _updateStatus(SyncStatus.idle);
      return await _doRequestPermissions();
    } catch (e) {
      _updateStatus(SyncStatus.error);
      errorHandler(e);
      return false;
    }
  }

  Future<bool> _doRequestPermissions() async {
    return await _channel.invokeMethod(
      WearableHealthDataConstants.methodRequestPermissions,
      _scopesToStringList(),
    );
  }

  List<String> _scopesToStringList() {
    return scope.map((scope) => scope.value).toList();
  }

  Future<bool> startCollecting() async {
    try {
      _updateStatus(SyncStatus.collecting);
      var result = await _doStartCollecting();
      _updateStatus(SyncStatus.completed);
      return result;
    } catch (e) {
      _updateStatus(SyncStatus.error);
      errorHandler(e);
      return false;
    }
  }

  Future<bool> _doStartCollecting() async {
    return await _channel.invokeMethod(
      WearableHealthDataConstants.methodStartCollecting,
      {},
    );
  }

  void _updateStatus(SyncStatus status) {
    _statusController.add(status);
  }

  void dispose() {
    _statusController.close();
  }

  Future<bool> stopCollecting() async {
    try {
      _updateStatus(SyncStatus.stopping);
      var result = _doStopCollecting();
      _updateStatus(SyncStatus.stopped);
      return result;
    } catch (e) {
      _updateStatus(SyncStatus.error);
      errorHandler(e);
      return false;
    }
  }

  Future<bool> _doStopCollecting() async {
    return await _channel.invokeMethod(
      WearableHealthDataConstants.methodStopCollecting, {}
    );
  }
}
