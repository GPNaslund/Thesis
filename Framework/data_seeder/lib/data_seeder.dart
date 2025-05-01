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

  Future<bool> hasPermissions() async {
    bool? hasPermissions = await methodChannel.invokeMethod<bool>(
      "hasPermissions",
    );
    return hasPermissions ?? false;
  }

  Future<bool> requestPermissions() async {
    bool? requestSuccess = await methodChannel.invokeMethod<bool>(
      "requestPermissions",
    );
    return requestSuccess ?? false;
  }
}
