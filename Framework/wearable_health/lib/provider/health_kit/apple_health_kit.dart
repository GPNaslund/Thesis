import 'package:flutter/services.dart';
import 'package:wearable_health/provider/enums/datastore_availability.dart';
import 'package:wearable_health/provider/health_kit/enums/method_types.dart';
import 'package:wearable_health/provider/provider.dart';

class AppleHealthKit implements Provider {
  final methodChannel = MethodChannel("wearable_health");

  @override
  Future<String> getPlatformVersion() async {
    final platformVersion = await methodChannel.invokeMethod<String>(
      MethodType.getPlatformVersion.value,
    );
    return platformVersion ?? "";
  }

  @override
  Future<bool> requestPermissions({required List<String> permissions}) async {
    final result = await methodChannel.invokeMethod<bool>(
      MethodType.requestPermission.value,
      {'permissions': permissions},
    );
    return result ?? false;
  }

  @override
  Future<bool> hasPermissions({required List<String> permissions}) async {
    final result = await methodChannel.invokeMethod<bool>("hasPermissions", {
      'permissions': permissions,
    });
    return result ?? false;
  }

  @override
  Future<DataStoreAvailability> checkDataStoreAvailability() async {
    final result = await methodChannel.invokeMethod<String>(
      MethodType.dataStoreAvailability.value,
    );
    return DataStoreAvailability.fromString(result ?? "unkown");
  }
}
