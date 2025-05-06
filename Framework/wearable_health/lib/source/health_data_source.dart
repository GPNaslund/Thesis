import 'package:flutter/material.dart';
import 'package:wearable_health/dto/health_data.dart';
import 'package:wearable_health/source/health_metric.dart';
import 'package:wearable_health/source/health_source_availability.dart';

abstract class HealthDataSource<T extends HealthMetric, S extends HealthData> {
  Future<String> getPlatformVersion();
  Future<List<T>> checkPermissions();
  Future<List<T>> requestPermissions(List<T> metrics);
  Future<List<S>> getData(List<T> metrics, DateTimeRange timeRange);
  Future<HealthSourceAvailability> checkHealthStoreAvailability();
}
