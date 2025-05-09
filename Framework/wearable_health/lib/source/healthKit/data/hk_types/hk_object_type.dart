class HKObjectType {
  late String identifier;

  HKObjectType(this.identifier);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HKObjectType &&
              runtimeType == other.runtimeType &&
              identifier == other.identifier;

  @override
  int get hashCode => identifier.hashCode;

  @override
  String toString() {
    return 'HKObjectType($identifier)';
  }
}