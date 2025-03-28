// lib/features/home/views/home_page.dart

import 'package:flutter/material.dart';
import '../../data_fetching/pages/health_metric_selection_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    return Text(
      "Welcome to the Plugin Test App",
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
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
          MaterialPageRoute(builder: (context) => HealthMetricSelectionPage()),
        );
      },
      child: Text("Choose Health Metric"),
    );
  }
}