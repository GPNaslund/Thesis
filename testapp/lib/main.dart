// lib/main.dart

import 'package:flutter/material.dart';
import 'features/home/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plugin Test App',
      home: HomePage(),
    );
  }
}