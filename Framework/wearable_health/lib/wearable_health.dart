import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wearable_health/services/providers/apple_health_provider.dart';
import 'package:wearable_health/services/auth/auth_config.dart';
import 'package:wearable_health/services/enums/health_data_type.dart';
import 'package:wearable_health/services/providers/health_connect_provider.dart';
import 'package:wearable_health/services/data_transformer/health_data_transformer.dart';
import 'package:wearable_health/services/providers/health_provider.dart';
import 'package:wearable_health/wearable_health_data_constants.dart';

enum SyncStatus { idle, collecting, transforming, completed, error}

typedef ErrorHandler = void Function(dynamic error);

class WearableHealth {
  final HealthProvider provider;
  final HealthDataTransformer transformer;
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
    required this.errorHandler,
    required this.scope,
  });

  static WearableHealth forHealthConnect(
    AuthConfig authConfig,
    List<HealthDataType> scope,
    HealthDataTransformer transformer,
    ErrorHandler errorHandler,
  ) {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Health Connect is only available on Android");
    }

    return WearableHealth._(
      provider: HealthConnectProvider(authConfig, scope),
      transformer: transformer,
      errorHandler: errorHandler,
      scope: scope,
    );
  }

  static WearableHealth forAppleHealth(
    AuthConfig authConfig,
    List<HealthDataType> scope,
    HealthDataTransformer transformer,
    ErrorHandler errorHandler,
  ) {
    if (!Platform.isIOS) {
      throw UnsupportedError("AppleHealth is only available for IOS");
    }

    return WearableHealth._(
      provider: AppleHealthProvider(authConfig, scope),
      transformer: transformer,
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

  Future<bool> _doRequestPermissions(BuildContext context) async {
    while (true) {
      final result = await _channel.invokeMethod(WearableHealthDataConstants.methodRequestPermissions);
      if (result == "SHOW_PRIVACY_POLICY") {
        await _showPrivacyPolicy(context);
        continue;
      }
      return result == true;
    }
  }

  Future<void> _showPrivacyPolicy(BuildContext context) async {
    if (provider.privacyPolicy != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: provider.privacyPolicy!),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DefaultPrivacyPolicyScreen())
      );
    }
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

}
