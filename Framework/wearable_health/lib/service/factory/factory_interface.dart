import 'package:flutter/services.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

/// Defines interface for accessing core plugin components and platform-specific factories.
/// Abstracts platform implementation details for cross-platform health data access.
abstract class FactoryInterface {
  /// Returns the method channel for native platform communication.
  MethodChannel getMethodChannel();

  /// Returns the JSON converter for safe data transformation.
  JsonConverter getJsonConverter();

  /// Returns the factory for Health Connect data objects (Android).
  HCDataFactory getHCDataFactory();

  /// Returns the factory for HealthKit data objects (iOS).
  HKDataFactory getHKDataFactory();
}
