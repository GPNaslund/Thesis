import 'package:wearable_health/provider/provider.dart';

class AppleHealthKit implements Provider {

  @override
  Future<String> getPlatformVersion() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> getPermissions({ required List<String> permissions }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasPermissions({ required List<String> permissions }) {
    throw UnimplementedError();
  }

}