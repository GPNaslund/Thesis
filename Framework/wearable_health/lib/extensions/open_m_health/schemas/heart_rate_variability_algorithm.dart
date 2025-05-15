enum HrvAlgorithm {
  rmssd("RMSSD"),
  sdnn("SDNN"),
  pnn50("pNN50"),
  triangularIndex("triangular_index"),
  hf("HF"),
  lf("LF"),
  lfhfRatio("LF_HF_ratio"),
  other("other");

  final String value;

  const HrvAlgorithm(this.value);

  Map<String, dynamic> toJson() {
    return { "heart_rate_variability_algorithm": value };
  }
}