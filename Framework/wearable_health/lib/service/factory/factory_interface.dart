import 'package:flutter/services.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

abstract class FactoryInterface {
  MethodChannel getMethodChannel();
  JsonConverter getJsonConverter();
  HCDataFactory getHCDataFactory();
  HKDataFactory getHKDataFactory();
}
