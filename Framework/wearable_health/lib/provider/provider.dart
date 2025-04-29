import 'package:flutter/material.dart';
import 'package:wearable_health/provider/data_converter.dart';
import 'package:wearable_health/provider/enums/datastore_availability.dart';
import 'package:wearable_health/provider/health_data.dart';

abstract class Provider {
  Future<String> getPlatformVersion();
  Future<bool> hasPermissions();
  Future<bool> requestPermissions();
  Future<DataStoreAvailability> checkDataStoreAvailability();
  Future<List<HealthData>> getData(
    DateTimeRange timeRange,
    DataConverter? converter,
  );
}
