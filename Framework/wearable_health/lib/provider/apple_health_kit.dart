import 'package:wearable_health/provider/enums/datastore_availability.dart';
import 'package:wearable_health/provider/provider.dart';

class AppleHealthKit implements Provider {
  @override
  Future<String> getPlatformVersion() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPermissions({required List<String> permissions}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasPermissions({required List<String> permissions}) {
    throw UnimplementedError();
  }

  @override
  Future<DataStoreAvailability> checkDataStoreAvailability() {
    throw UnimplementedError();
  }
}
