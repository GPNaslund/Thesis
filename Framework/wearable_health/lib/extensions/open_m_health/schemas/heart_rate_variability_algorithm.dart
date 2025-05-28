/// Enum representing different algorithms used to calculate Heart Rate Variability (HRV).
///
/// Each enum value corresponds to a specific HRV algorithm and holds a string representation
/// that can be used for serialization or display purposes.
enum HrvAlgorithm {
  /// Root Mean Square of Successive Differences (RMSSD).
  /// A time-domain measure reflecting short-term, high-frequency HRV.
  rmssd("RMSSD"),

  /// Standard Deviation of NN intervals (SDNN).
  /// A time-domain measure reflecting overall HRV.
  sdnn("SDNN"),

  /// Percentage of successive NN interval differences greater than 50 ms (pNN50).
  /// A time-domain measure sensitive to vagal tone.
  pnn50("pNN50"),

  /// HRV Triangular Index.
  /// A geometric measure of HRV.
  triangularIndex("triangular_index"),

  /// High Frequency power (HF).
  /// A frequency-domain measure (typically 0.15-0.4 Hz) reflecting parasympathetic activity.
  hf("HF"),

  /// Low Frequency power (LF).
  /// A frequency-domain measure (typically 0.04-0.15 Hz) reflecting both sympathetic and parasympathetic activity.
  lf("LF"),

  /// Ratio of Low Frequency power to High Frequency power (LF/HF ratio).
  /// Often used as an indicator of sympathovagal balance.
  lfhfRatio("LF_HF_ratio"),

  /// Represents any other algorithm not explicitly listed.
  other("other");

  /// The string representation of the HRV algorithm.
  final String value;

  /// Constructs an [HrvAlgorithm] enum value.
  ///
  /// [value] is the string representation of the algorithm.
  const HrvAlgorithm(this.value);

  /// Converts the enum to a JSON object.
  ///
  /// Returns a map with the key "heart_rate_variability_algorithm" and the algorithm's string value.
  Map<String, dynamic> toJson() {
    return {"heart_rate_variability_algorithm": value};
  }
}
