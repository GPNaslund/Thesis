abstract class Provider {
  Future<bool> hasPermissions();
  Future<bool> getPermissions();
}