import 'package:wearable_health/provider/enums/datastore_availability.dart';

abstract class Provider {
  Future<String> getPlatformVersion();
  Future<bool> hasPermissions({required List<String> permissions});
  Future<bool> requestPermissions({required List<String> permissions});
  Future<DataStoreAvailability> checkDataStoreAvailability();
}
