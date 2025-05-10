import 'dart:io';

import 'package:flutter/material.dart';

import 'healthConnect.dart';
import 'healthKit.dart';

void main() {
  Widget appToRun;

  if (Platform.isAndroid) {
    print("Running Android specific App");
    appToRun = const HealthConnectApp();


  } else if (Platform.isIOS) {
    print("Running iOS specific App");
    appToRun = const HealthKitApp();

  } else {
    print("Unsupported platform: ${Platform.operatingSystem}");
    appToRun = MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Unsupported Platform")),
        body: Center(
          child: Text("This application is designed for Android or iOS, but is running on ${Platform.operatingSystem}."),
        ),
      ),
    );
  }

  runApp(appToRun);
}