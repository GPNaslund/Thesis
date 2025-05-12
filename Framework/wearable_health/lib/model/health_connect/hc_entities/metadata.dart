class HealthConnectMetadata {
  late String? clientRecordId;
  late int? clientRecordVersion;
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
}
