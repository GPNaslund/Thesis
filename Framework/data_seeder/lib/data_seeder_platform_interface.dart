import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'data_seeder_method_channel.dart';

abstract class DataSeederPlatform extends PlatformInterface {
  /// Constructs a DataSeederPlatform.
  DataSeederPlatform() : super(token: _token);

  static final Object _token = Object();

  static DataSeederPlatform _instance = MethodChannelDataSeeder();

  /// The default instance of [DataSeederPlatform] to use.
  ///
  /// Defaults to [MethodChannelDataSeeder].
  static DataSeederPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DataSeederPlatform] when
  /// they register themselves.
  static set instance(DataSeederPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
