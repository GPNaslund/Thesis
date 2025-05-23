import 'package:flutter/services.dart';

import 'data_seeder_platform_interface.dart';

class DataSeeder {
  MethodChannel methodChannel = MethodChannel("data_seeder");

  Future<String?> getPlatformVersion() {
    return methodChannel.invokeMethod("getPlatformVersion");
  }

  Future<bool> seedData() async {
    bool? success = await methodChannel.invokeMethod<bool>("seedData");
    return success ?? false;
  }

  Future<bool> seedDataLive() async {
    bool? success = await methodChannel.invokeMethod<bool>("seedLive");
    return success ?? false;
  }

  Future<bool> stopSeedDataLive() async {
    bool? success = await methodChannel.invokeMethod<bool>("stopSeedLive");
    return success ?? false;
  }

  Future<bool> hasPermissions() async {
    bool? hasPermissions = await methodChannel.invokeMethod<bool>(
      "hasHealthConnectPermissions",
    );


    bool? hasSysPermissions = await methodChannel.invokeMethod<bool>(
      "hasSystemPermissions",
    );

    return hasPermissions! && hasSysPermissions! ?? false;
  }

  Future<bool> requestPermissions() async {
    bool? requestSuccess = await methodChannel.invokeMethod<bool>(
      "requestHealthConnectPermissions",
    );

    bool? requestSystemSuccess = await methodChannel.invokeMethod<bool>(
      "requestSystemPermissions",
    );

    if (requestSystemSuccess! && requestSuccess!) {
      return true;
    }
    return false;
  }
}
