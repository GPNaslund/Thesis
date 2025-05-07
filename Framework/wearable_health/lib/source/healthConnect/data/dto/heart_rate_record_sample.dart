class HeartRateRecordSample {
  DateTime time;
  int beatsPerMinute;

  HeartRateRecordSample(this.time, this.beatsPerMinute);

  factory HeartRateRecordSample.fromMap(Map<String, dynamic> serialized) {
    return HeartRateRecordSample(
      DateTime.parse(serialized["time"]),
      serialized["beatsPerMinute"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time.toUtc().toIso8601String(),
      "beatsPerMinute": beatsPerMinute,
    };
  }
}