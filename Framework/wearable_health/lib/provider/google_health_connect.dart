import 'package:flutter/services.dart';
import 'package:wearable_health/provider/provider.dart';

class GoogleHealthConnect implements Provider {
  final methodChannel = MethodChannel("wearable_health");

  @override
  Future<String> getPlatformVersion() async {
    final platformVersion = await methodChannel.invokeMethod("getPlatformVersion");
    return platformVersion;
  }

  @override
  Future<bool> getPermissions({ required List<String> permissions }) async {
    final result = await methodChannel.invokeMethod<bool>("getPermissions", {
      'permissions': permissions
    },);
    return result ?? false;
  }

  @override
  Future<bool> hasPermissions({ required List<String> permissions }) async {
    final result = await methodChannel.invokeMethod<bool>("hasPermissions", {
      'permissions': permissions
    },);
    return result ?? false;
  }

}