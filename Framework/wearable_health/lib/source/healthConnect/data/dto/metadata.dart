class HealthConnectMetadata {
  String? clientRecordId;
  int clientRecordVersion;
  String dataOrigin;
  String? device;
  String id;
  DateTime lastModifiedTime;
  int recordingMethod;

  HealthConnectMetadata({
    this.clientRecordId,
    required this.clientRecordVersion,
    required this.dataOrigin,
    this.device,
    required this.id,
    required this.lastModifiedTime,
    required this.recordingMethod,
  });

  factory HealthConnectMetadata.fromMap(Map<dynamic, dynamic> serialized) {
    T getField<T>(Map<dynamic, dynamic> map, String key, {bool isNullable = false}) {
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

    final String? clientRecordId = getField<String?>(serialized, "clientRecordId", isNullable: true);
    final int clientRecordVersion = getField<int>(serialized, "clientRecordVersion");
    final String dataOrigin = getField<String>(serialized, "dataOrigin");
    final String? device = getField<String?>(serialized, "device", isNullable: true);
    final String id = getField<String>(serialized, "id");
    final String lastModifiedTimeString = getField<String>(serialized, "lastModifiedTime");
    final int recordingMethod = getField<int>(serialized, "recordingMethod");

    DateTime lastModifiedTimeDateTime;
    try {
      lastModifiedTimeDateTime = DateTime.parse(lastModifiedTimeString);
    } catch (e) {
      throw FormatException(
          "Invalid DateTime format for 'lastModifiedTime': '$lastModifiedTimeString'. Error: $e");
    }

    return HealthConnectMetadata(
      clientRecordId: clientRecordId,
      clientRecordVersion: clientRecordVersion,
      dataOrigin: dataOrigin,
      device: device,
      id: id,
      lastModifiedTime: lastModifiedTimeDateTime,
      recordingMethod: recordingMethod,
    );
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