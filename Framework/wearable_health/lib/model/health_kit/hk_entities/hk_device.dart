/// Represents a device that provides health data to HealthKit.
///
/// Contains identifying information about hardware and software
/// that collected or generated health measurements.
class HKDevice {
  /// Optional name of the device.
  late String? name;

  /// Optional name of the device manufacturer.
  late String? manufacturer;

  /// Optional model identifier or name of the device.
  late String? model;

  /// Optional hardware version of the device.
  late String? hardwareVersion;

  /// Optional software or firmware version running on the device.
  late String? softwareVersion;

  /// Creates a new device representation with the specified parameters.
  ///
  /// All parameters are optional and can be null if the information
  /// is not available.
  HKDevice({
    this.name,
    this.manufacturer,
    this.model,
    this.hardwareVersion,
    this.softwareVersion,
  });
}
