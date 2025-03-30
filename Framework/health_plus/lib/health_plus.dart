import 'dart:io';

import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:health_plus/provider/health_provider.dart';
import 'package:health_plus/provider/health_provider_type.dart';
import 'package:health_plus/services/mobile_health_schema_converter.dart';
import 'package:logging/logging.dart';

import 'health_plus_platform_interface.dart';

class HealthPlus {
  final log = Logger("HealthPlus");

  Future<String?> getPlatformVersion() {
    return HealthPlusPlatform.instance.getPlatformVersion();
  }

  HealthProvider getHealthProvider(
    HealthProviderType type,
    List<HealthDataType> types,
    MobileHealthSchemaConverter schemaConverter,
  ) {
    switch (type) {
      case HealthProviderType.appleHealthKit:
        if (Platform.isIOS) {
          return HealthProvider.appleHealthKit(types, schemaConverter);
        } else {
          throw PlatformException(code: "INVALID_PLATFORM");
        }
      case HealthProviderType.googleHealthConnect:
        if (Platform.isAndroid) {
          return HealthProvider.googleHealthConnect(types, schemaConverter);
        } else {
          throw PlatformException(code: "INVALID_PLATFORM");
        }
    }
  }
}
