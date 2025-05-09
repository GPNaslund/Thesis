class HKDevice {
  late String? name;
  late String? manufacturer;
  late String? model;
  late String? hardwareVersion;
  late String? softwareVersion;

  HKDevice({
    this.name,
    this.manufacturer,
    this.model,
    this.hardwareVersion,
    this.softwareVersion,
  });

  HKDevice.fromMap(Map<String, dynamic> json) {
    name = json['name'] as String?;
    manufacturer = json['manufacturer'] as String?;
    model = json['model'] as String?;
    hardwareVersion = json['hardwareVersion'] as String?;
    softwareVersion = json['softwareVersion'] as String?;
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