import 'package:flutter_test/flutter_test.dart';
import 'package:data_seeder/data_seeder.dart';
import 'package:data_seeder/data_seeder_platform_interface.dart';
import 'package:data_seeder/data_seeder_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDataSeederPlatform
    with MockPlatformInterfaceMixin
    implements DataSeederPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DataSeederPlatform initialPlatform = DataSeederPlatform.instance;

  test('$MethodChannelDataSeeder is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDataSeeder>());
  });

  test('getPlatformVersion', () async {
    DataSeeder dataSeederPlugin = DataSeeder();
    MockDataSeederPlatform fakePlatform = MockDataSeederPlatform();
    DataSeederPlatform.instance = fakePlatform;

    expect(await dataSeederPlugin.getPlatformVersion(), '42');
  });
}
