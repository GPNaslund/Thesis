import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wearable_health_platform_interface.dart';

/// An implementation of [WearableHealthPlatform] that uses method channels.
class MethodChannelWearableHealth extends WearableHealthPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wearable_health');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  
}
