import 'package:health/health.dart';
import 'package:health_plus/provider/apple_health_kit.dart';
import 'package:health_plus/provider/google_health_connect.dart';
import 'package:health_plus/schemas/mobile_health_schema/mobile_health_schema.dart';
import 'package:health_plus/services/mobile_health_schema_converter.dart';

abstract class HealthProvider {
  Future<bool?> checkPermissions();

  Future<bool> requestPermissions();

  Future<List<HealthDataPoint>> getData();

  Future<List<MobileHealthSchema>> getDataInMobileHealthSchemaFormat();

  factory HealthProvider.appleHealthKit(
    List<HealthDataType> types,
    MobileHealthSchemaConverter schemaConverter,
  ) {
    return AppleHealthKit(types, schemaConverter);
  }

  factory HealthProvider.googleHealthConnect(
    List<HealthDataType> types,
    MobileHealthSchemaConverter schemaConverter,
  ) {
    return GoogleHealthConnect(types, schemaConverter);
  }
}
