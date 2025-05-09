class HKSource {
  final String bundleIdentifier;
  final String name;

  const HKSource({
    required this.bundleIdentifier,
    required this.name,
  });

  factory HKSource.fromJson(Map<String, dynamic> json) {
    return HKSource(
      bundleIdentifier: json['bundleIdentifier'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bundleIdentifier': bundleIdentifier,
      'name': name,
    };
  }
}