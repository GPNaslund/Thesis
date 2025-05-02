import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'data_seeder_platform_interface.dart';

/// An implementation of [DataSeederPlatform] that uses method channels.
class MethodChannelDataSeeder extends DataSeederPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('data_seeder');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
