/// Enum representing the methods used to measure the physiological signals
/// from which Heart Rate Variability (HRV) is derived.
///
/// Each enum value corresponds to a specific measurement method and holds
/// a string representation that can be used for serialization or display purposes.
enum HrvMeasurementMethod {
  /// Electrocardiogram (ECG or EKG).
  /// HRV is derived from the R-R intervals measured from an ECG signal.
  /// This is generally considered the gold standard for HRV measurement.
  ecg("ECG"),

  /// Photoplethysmography (PPG).
  /// HRV is derived from the pulse-to-pulse intervals (or peak-to-peak intervals)
  /// measured from a PPG signal, which detects blood volume changes in the
  /// microvascular bed of tissue.
  ppg("PPG"),

  /// Represents any other measurement method not explicitly listed.
  /// This could include methods based on seismocardiography, ballistocardiography, etc.
  other("other");

  /// The string representation of the HRV measurement method.
  final String value;

  /// Constructs an [HrvMeasurementMethod] enum value.
  ///
  /// [value] is the string representation of the measurement method.
  const HrvMeasurementMethod(this.value);

  /// Converts the enum to a JSON object suitable for serialization.
  ///
  /// Returns a map with the key "heart_rate_variability_measurement_method"
  /// and the measurement method's string value.
  Map<String, dynamic> toJson() {
    return { "heart_rate_variability_measurement_method": value};
  }

}