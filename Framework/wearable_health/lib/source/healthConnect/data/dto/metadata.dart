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

  factory HealthConnectMetadata.fromMap(Map<String, dynamic> serialized) {
    String? clientRecordId = serialized["clientRecordId"];
    int clientRecordVersion = serialized["clientRecordVersion"];
    String dataOrigin = serialized["dataOrigin"];
    String? device = serialized["device"];
    String id = serialized["id"];
    String lastModifiedTime = serialized["lastModifiedTime"];
    int recordingMethod = serialized["recordingMethod"];

    DateTime lastModifiedTimeDateTime = DateTime.parse(lastModifiedTime);

    return HealthConnectMetadata(
      clientRecordVersion: clientRecordVersion,
      dataOrigin: dataOrigin,
      id: id,
      lastModifiedTime: lastModifiedTimeDateTime,
      recordingMethod: recordingMethod,
    );
  }
}
