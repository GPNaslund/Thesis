import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'health_plus_platform_interface.dart';

/// An implementation of [HealthPlusPlatform] that uses method channels.
class MethodChannelHealthPlus extends HealthPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('health_plus');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
