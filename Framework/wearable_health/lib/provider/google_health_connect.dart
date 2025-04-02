import 'package:flutter/services.dart';
import 'package:wearable_health/provider/provider.dart';

class GoogleHealthConnect implements Provider {
  final methodChannel = MethodChannel("wearable_health");

  @override
  Future<bool> getPermissions() async {
    final getPermissionsResult = await methodChannel.invokeMethod("getPermissions");
    switch (getPermissionsResult) {
      case "hasPermissions":
        return true;
      default: 
        return false;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    final hasPermissionsStatus = await methodChannel.invokeMethod("hasPermissions");
    switch (hasPermissionsStatus) {
      case "true":
        return true;
      default:
        return false;
    }

  }

}