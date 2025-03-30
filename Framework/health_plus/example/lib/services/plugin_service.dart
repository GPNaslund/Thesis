import 'dart:io';
import 'package:health/health.dart';
import 'package:health_plus/health_plus.dart';
import 'package:health_plus/provider/health_provider.dart';
import 'package:health_plus/provider/health_provider_type.dart';
import 'package:health_plus/services/default_mobile_health_schema_converter.dart';

import '../../constants/metrics.dart';
import '../../constants/metric_mapper.dart';

class PluginService {
  late HealthProvider _provider;
  bool _initialized = false;
  HealthDataType? _currentType;

  // Initialize the provider with a list of health data types
  Future<void> _initProvider(List<HealthDataType> types) async {
    final converter = DefaultMobileHealthSchemaConverter();

    _provider = Platform.isIOS
        ? HealthPlus().getHealthProvider(
      HealthProviderType.appleHealthKit,
      types,
      converter,
    )
        : HealthPlus().getHealthProvider(
      HealthProviderType.googleHealthConnect,
      types,
      converter,
    );

    await _provider.initialize();
    _initialized = true;
  }

  // Ask for permissions for all supported metrics
  Future<bool> initWithPermissions() async {
    if (!_initialized) {
      final allTypes = HealthMetric.values
          .map(mapToHealthDataType)
          .whereType<HealthDataType>()
          .toList();

      await _initProvider(allTypes);
    }

    final hasPermissions = await _provider.checkPermissions();
    if (hasPermissions != true) {
      final granted = await _provider.requestPermissions();
      return granted;
    }

    return true;
  }

  // Fetch data for a specific metric in raw or formatted format
  Future<String> fetchHealthData(HealthMetric metric, String format) async {
    final type = mapToHealthDataType(metric); // uses metric_mapper.dart
    if (type == null) return "Unsupported metric: ${metric.displayName}";

    if (!_initialized || _currentType != type) {
      await _initProvider([type]);
      _currentType = type;
    }

    try {
      if (format.toLowerCase().contains("raw")) {
        final rawData = await _provider.getData();
        final filtered = rawData.where((e) => e.type == type).toList();

        if (filtered.isEmpty) return "No data found for ${metric.displayName}.";

        return filtered
            .map((e) => "${e.type.name}: ${e.value}")
            .join("\n");
      } else {
        final formatted = await _provider.getDataInMobileHealthSchemaFormat();
        final filtered = formatted.where((e) =>
            e.toJson().toString().toLowerCase().contains(
                metric.name.toLowerCase())
        ).toList();

        if (filtered.isEmpty) {
          return "No formatted data found for ${metric.displayName}.";
        }

        return filtered
            .map((e) => e.toJson().toString())
            .join("\n\n");
      }
    } catch (e) {
      return "Error while fetching ${metric.displayName} data: $e";
    }
  }
}
