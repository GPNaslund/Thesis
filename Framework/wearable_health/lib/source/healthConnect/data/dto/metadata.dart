class HealthConnectMetadata {
  late String? clientRecordId;
  late int clientRecordVersion;
  late String dataOrigin;
  late String? device;
  late String id;
  late DateTime lastModifiedTime;
  late int recordingMethod;

  HealthConnectMetadata({
    this.clientRecordId,
    required this.clientRecordVersion,
    required this.dataOrigin,
    this.device,
    required this.id,
    required this.lastModifiedTime,
    required this.recordingMethod,
  });

  HealthConnectMetadata.fromJson(Map<dynamic, dynamic> jsonData) {
    final String? clientRecordId = _getField<String?>(jsonData, "clientRecordId", isNullable: true);
    this.clientRecordId = clientRecordId;

    final int clientRecordVersion = _getField<int>(jsonData, "clientRecordVersion");
    this.clientRecordVersion = clientRecordVersion;

    final String dataOrigin = _getField<String>(jsonData, "dataOrigin");
    this.dataOrigin = dataOrigin;

    final String? device = _getField<String?>(jsonData, "device", isNullable: true);
    this.device = device;

    final String id = _getField<String>(jsonData, "id");
    this.id = id;

    final String lastModifiedTimeString = _getField<String>(jsonData, "lastModifiedTime");

    final int recordingMethod = _getField<int>(jsonData, "recordingMethod");
    this.recordingMethod = recordingMethod;


    DateTime lastModifiedTime;
    try {
      lastModifiedTime = DateTime.parse(lastModifiedTimeString);
      this.lastModifiedTime = lastModifiedTime;
    } catch (e) {
      throw FormatException(
          "Invalid DateTime format for 'lastModifiedTime': '$lastModifiedTimeString'. Error: $e");
    }
  }

  T _getField<T>(Map<dynamic, dynamic> map, String key, {bool isNullable = false}) {
    final value = map[key];
    if (value == null) {
      if (isNullable) {
        return null as T;
      } else {
        throw FormatException("Missing required field '$key' in HealthConnectMetadata map.");
      }
    }
    if (value is T) {
      return value;
    }
    if (T == int && value is num) {
      return value.toInt() as T;
    }
    throw FormatException(
        "Invalid type for field '$key' in HealthConnectMetadata map. Expected $T, got ${value.runtimeType}. Value: $value");
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> metadataJson = {
      "clientRecordVersion": clientRecordVersion,
      "dataOrigin": dataOrigin,
      "id": id,
      "lastModifiedTime": lastModifiedTime.toUtc().toIso8601String(),
      "recordingMethod":recordingMethod
    };

    if (clientRecordId != null) {
      metadataJson["clientRecordId"] = clientRecordId;
    }

    if (device != null) {
      metadataJson["device"] = device;
    }

    return metadataJson;
  }

}