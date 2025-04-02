import 'package:flutter_test/flutter_test.dart';
import 'package:wearable_health/wearable_health.dart';
import 'package:wearable_health/wearable_health_platform_interface.dart';
import 'package:wearable_health/wearable_health_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWearableHealthPlatform
    with MockPlatformInterfaceMixin
    implements WearableHealthPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WearableHealthPlatform initialPlatform = WearableHealthPlatform.instance;

  test('$MethodChannelWearableHealth is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWearableHealth>());
  });

  test('getPlatformVersion', () async {
    WearableHealth wearableHealthPlugin = WearableHealth();
    MockWearableHealthPlatform fakePlatform = MockWearableHealthPlatform();
    WearableHealthPlatform.instance = fakePlatform;

    expect(await wearableHealthPlugin.getPlatformVersion(), '42');
  });
}
