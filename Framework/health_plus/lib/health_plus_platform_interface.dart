import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'health_plus_method_channel.dart';

abstract class HealthPlusPlatform extends PlatformInterface {
  /// Constructs a HealthPlusPlatform.
  HealthPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static HealthPlusPlatform _instance = MethodChannelHealthPlus();

  /// The default instance of [HealthPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelHealthPlus].
  static HealthPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HealthPlusPlatform] when
  /// they register themselves.
  static set instance(HealthPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
