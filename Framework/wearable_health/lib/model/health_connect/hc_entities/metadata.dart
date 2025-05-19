/// Contains metadata associated with health records from Health Connect.
///
/// Includes information about the record's origin, modification time,
/// and recording method.
class HealthConnectMetadata {
  /// Optional client-specific identifier for the record.
  late String? clientRecordId;

  /// Version of the client record, if versioning is used.
  late int? clientRecordVersion;

  /// Source application or service that created the data.
  late String dataOrigin;

  /// Optional identifier of the device that recorded the data.
  late String? device;

  /// Unique identifier for this health record.
  late String id;

  /// Timestamp when this record was last modified.
  late DateTime lastModifiedTime;

  /// Integer code representing how the data was recorded.
  ///
  /// Refer to Health Connect documentation for specific recording method codes.
  late int recordingMethod;

  /// Creates a new metadata instance with the specified parameters.
  HealthConnectMetadata({
    this.clientRecordId,
    this.clientRecordVersion,
    required this.dataOrigin,
    this.device,
    required this.id,
    required this.lastModifiedTime,
    required this.recordingMethod,
  });
}
