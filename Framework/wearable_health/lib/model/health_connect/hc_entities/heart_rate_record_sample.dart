class HeartRateRecordSample {
  late DateTime time;
  late int beatsPerMinute;

  HeartRateRecordSample(this.time, this.beatsPerMinute);

  @override
  String toString() {
    return '{time: ${time.toIso8601String()}, bpm: $beatsPerMinute}';
  }
}