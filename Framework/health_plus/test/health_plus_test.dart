import 'package:flutter_test/flutter_test.dart';
import 'package:health_plus/health_plus.dart';
import 'package:health_plus/health_plus_platform_interface.dart';
import 'package:health_plus/health_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHealthPlusPlatform
    with MockPlatformInterfaceMixin
    implements HealthPlusPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final HealthPlusPlatform initialPlatform = HealthPlusPlatform.instance;

  test('$MethodChannelHealthPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHealthPlus>());
  });

  test('getPlatformVersion', () async {
    HealthPlus healthPlusPlugin = HealthPlus();
    MockHealthPlusPlatform fakePlatform = MockHealthPlusPlatform();
    HealthPlusPlatform.instance = fakePlatform;

    expect(await healthPlusPlugin.getPlatformVersion(), '42');
  });
}
