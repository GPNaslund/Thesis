import 'package:wearable_health/provider/provider.dart';

class AppleHealthKit implements Provider {

  @override
  Future<bool> getPermissions() {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasPermissions() {
    throw UnimplementedError();
  }

}