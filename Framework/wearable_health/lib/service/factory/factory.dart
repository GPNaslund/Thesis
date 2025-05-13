import 'package:flutter/services.dart';
import 'package:wearable_health/service/converters/json/json_converter.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/factory/factory_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

/// Concrete implementation of FactoryInterface providing access to platform-specific
/// health data factories and communication channels.
class FactoryImpl implements FactoryInterface {
  /// Channel for communicating with native platform code for health data.
  MethodChannel channel = MethodChannel("wearable_health");

  /// Utility for safely converting JSON data structures.
  JsonConverterImpl jsonConverter = JsonConverterImpl();

  /// Factory for creating Health Connect (Android) data objects.
  late HCDataFactory hcDataFactory;

  /// Factory for creating HealthKit (iOS) data objects.
  late HKDataFactory hkDataFactory;

  /// Initializes the factory with platform-specific data factories.
  FactoryImpl() {
    hcDataFactory = HCDataFactoryImpl(jsonConverter);
    hkDataFactory = HKDataFactoryImpl(jsonConverter);
  }

  /// Returns the method channel for native platform communication.
  @override
  MethodChannel getMethodChannel() {
    return channel;
  }

  /// Returns the JSON converter for safe data transformation.
  @override
  JsonConverter getJsonConverter() {
    return jsonConverter;
  }

  /// Returns the factory for Health Connect data objects (Android).
  @override
  HCDataFactory getHCDataFactory() {
    return hcDataFactory;
  }

  /// Returns the factory for HealthKit data objects (iOS).
  @override
  HKDataFactory getHKDataFactory() {
    return hkDataFactory;
  }
}
