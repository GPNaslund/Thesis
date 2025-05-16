// lib/features/home/home_page.dart

import 'package:flutter/material.dart';
import '../permissions/permissions_page.dart';

/// home/landing page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PermissionsPage()),
            );
          },
          child: const Text("Choose Health Metric"),
        ),
      ),
    );
  }
}