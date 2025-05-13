// lib/services/data_seeding_service.dart

import 'package:data_seeder/data_seeder.dart';

class DataSeedingService {
  final DataSeeder _seeder = DataSeeder();

  Future<void> seedMockDataIfAvailable() async {
    final hasPermissions = await _seeder.requestPermissions();
    if (!hasPermissions) return;

    final success = await _seeder.seedData();
    if (!success) {
      print('Data seeding failed');
    } else {
      print('Mock data seeded successfully');
    }
  }
}