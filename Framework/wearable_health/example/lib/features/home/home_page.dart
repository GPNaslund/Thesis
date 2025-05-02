// lib/features/home/home_page.dart

import 'package:flutter/material.dart';
import '../permissions/permissions_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final grantedMetrics = await Navigator.push<List<String>>(
              context,
              MaterialPageRoute(
                builder: (context) => const PermissionsPage(),
              ),
            );

            if (grantedMetrics != null && context.mounted) {
              Navigator.pushNamed(
                context,
                '/metricSelection',
                arguments: grantedMetrics,
              );
            }
          },
          child: const Text("Choose Health Metric"),
        ),
      ),
    );
  }
}
