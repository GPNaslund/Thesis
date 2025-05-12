import 'package:flutter/services.dart';
import 'package:wearable_health/service/converters/json/json_converter.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
import 'package:wearable_health/service/factory/factory_interface.dart';
import 'package:wearable_health/service/health_connect/data_factory.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

class FactoryImpl implements FactoryInterface {
  MethodChannel channel = MethodChannel("wearable_health");
  JsonConverterImpl jsonConverter = JsonConverterImpl();
  late HCDataFactory hcDataFactory;
  late HKDataFactory hkDataFactory;

  FactoryImpl() {
    hcDataFactory = HCDataFactoryImpl(jsonConverter);
    hkDataFactory = HKDataFactoryImpl(jsonConverter);
  }

  @override
  MethodChannel getMethodChannel() {
    return channel;
  }

  @override
  JsonConverter getJsonConverter() {
    return jsonConverter;
  }

  @override
  HCDataFactory getHCDataFactory() {
    return hcDataFactory;
  }

  @override
  HKDataFactory getHKDataFactory() {
    return hkDataFactory;
  }
}
