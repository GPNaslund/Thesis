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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            HomeTitle(),
            SizedBox(height: 20),
            HomeButton(),
          ],
        ),
      ),
    );
  }
}

class HomeTitle extends StatelessWidget {
  const HomeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Welcome to the Wearable Health Test App",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      textAlign: TextAlign.center,
    );
  }
}

class HomeButton extends StatelessWidget {
  const HomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PermissionsPage()),
        );
      },
      child: const Text("Choose Health Metric"),
    );
  }
}
