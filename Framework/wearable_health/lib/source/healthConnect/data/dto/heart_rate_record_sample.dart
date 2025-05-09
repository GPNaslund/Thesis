class HeartRateRecordSample {
  late DateTime time;
  late int beatsPerMinute;

  HeartRateRecordSample(this.time, this.beatsPerMinute);

  HeartRateRecordSample.fromJson(Map<String, dynamic> jsonData) {
    var time = jsonData["time"] is String
      ? DateTime.parse(jsonData["time"])
      : throw FormatException("Expected String type");

    this.time = time;

    var beatsPerMinute = jsonData["beatsPerMinute"] is int
      ? jsonData["beatsPerMinute"]
      : throw FormatException("Expected integer");

    this.beatsPerMinute = beatsPerMinute;
  }

  Map<String, dynamic> toJson() {
    return {
      "time": time.toUtc().toIso8601String(),
      "beatsPerMinute": beatsPerMinute,
    };
  }
}