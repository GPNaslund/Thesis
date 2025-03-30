// lib/features/data_fetching/controllers/data_fetching_controller.dart

import '../../../services/plugin_service.dart';
import '../../../constants/metrics.dart';

class DataFetchingController {
  final PluginService _pluginService = PluginService();

  Future<String> getHealthData(HealthMetric metric, String format) async {
    return await _pluginService.fetchHealthData(metric, format);
  }
}