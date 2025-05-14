enum HrvMeasurementMethod {
  ecg("ECG"),
  ppg("PPG"),
  other("other");

  final String value;

  const HrvMeasurementMethod(this.value);

  Map<String, dynamic> toJson() {
    return { "heart_rate_variability_measurement_method": value };
  }

}