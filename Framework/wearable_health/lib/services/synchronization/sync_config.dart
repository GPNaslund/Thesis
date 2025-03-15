import 'package:wearable_health/services/enums/battery_level.dart';
import 'package:wearable_health/services/enums/network_type.dart';

class SyncConfig {
  final Duration interval;
  final int batchSize;
  final NetworkType networkType;
  final BatteryLevel batteryLevel;

  SyncConfig({
    required this.interval,
    required this.batchSize,
    required this.networkType,
    required this.batteryLevel,
  });
}
