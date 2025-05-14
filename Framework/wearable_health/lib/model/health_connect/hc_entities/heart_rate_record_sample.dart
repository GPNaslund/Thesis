/// Represents a single heart rate measurement sample.
///
/// Contains a timestamp and the measured heart rate in beats per minute.
class HeartRateRecordSample {
  /// The timestamp when this heart rate sample was recorded.
  late DateTime time;

  /// The measured heart rate value in beats per minute (BPM).
  late int beatsPerMinute;

  /// Creates a new heart rate sample with the specified time and value.
  HeartRateRecordSample(this.time, this.beatsPerMinute);

  @override
  String toString() {
    return '{time: ${time.toIso8601String()}, bpm: $beatsPerMinute}';
  }
}
