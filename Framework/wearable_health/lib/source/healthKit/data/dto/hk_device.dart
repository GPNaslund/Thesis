class HKDevice {
  final String? name;
  final String? manufacturer;
  final String? model;
  final String? hardwareVersion;
  final String? softwareVersion;

  const HKDevice({
    this.name,
    this.manufacturer,
    this.model,
    this.hardwareVersion,
    this.softwareVersion,
  });

  factory HKDevice.fromJson(Map<String, dynamic> json) {
    return HKDevice(
      name: json['name'] as String?,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      hardwareVersion: json['hardwareVersion'] as String?,
      softwareVersion: json['softwareVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'manufacturer': manufacturer,
      'model': model,
      'hardwareVersion': hardwareVersion,
      'softwareVersion': softwareVersion,
    };
  }
}