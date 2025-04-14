abstract class Provider {
  Future<String> getPlatformVersion();
  Future<bool> hasPermissions({required List<String> permissions});
  Future<bool> getPermissions({required List<String> permissions});
}