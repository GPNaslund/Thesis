import 'package:flutter/material.dart';
import 'android/android_wearable_health.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wearable Health Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AndroidWearableHealth(),
    );
  }
}