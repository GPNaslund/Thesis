import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wearable_health_method_channel.dart';

abstract class WearableHealthPlatform extends PlatformInterface {
  /// Constructs a WearableHealthPlatform.
  WearableHealthPlatform() : super(token: _token);

  static final Object _token = Object();

  static WearableHealthPlatform _instance = MethodChannelWearableHealth();

  /// The default instance of [WearableHealthPlatform] to use.
  ///
  /// Defaults to [MethodChannelWearableHealth].
  static WearableHealthPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WearableHealthPlatform] when
  /// they register themselves.
  static set instance(WearableHealthPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);

    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
