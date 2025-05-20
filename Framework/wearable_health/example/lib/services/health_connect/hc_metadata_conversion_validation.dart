import 'dart:developer';

import 'package:wearable_health/model/health_connect/hc_entities/metadata.dart';

bool isValidHCMetaData(
  Map<String, dynamic> rawData,
  HealthConnectMetadata metadata,
) {
  var isValid = true;
  if (rawData["dataOrigin"] != metadata.dataOrigin) {
    log(
      "Found discrepancy: raw metadata data origin: ${rawData["dataOrigin"]} - obj metadata data origin: ${metadata.dataOrigin}",
    );
    return !isValid;
  }

  if (rawData["id"] != metadata.id) {
    log(
      "Found discrepancy: raw metadata data id: ${rawData["id"]} - obj metadata id: ${metadata.id}",
    );
    return !isValid;
  }

  if (!DateTime.parse(
    rawData["lastModifiedTime"],
  ).isAtSameMomentAs(metadata.lastModifiedTime)) {
    log(
      "Found discrepancy: raw metadata last modified time: ${rawData["lastModifiedTime"]} - obj metadata lastModifiedTime ${metadata.lastModifiedTime}",
    );
    return !isValid;
  }

  if (rawData["recordingMethod"] != metadata.recordingMethod) {
    log(
      "Found discrepancy: raw metadata recording method: ${rawData["recordingMethod"]} - obj metadata recording method ${metadata.recordingMethod}",
    );
    return !isValid;
  }

  if (rawData["clientRecordId"] != null &&
      rawData["clientRecordId"] != metadata.clientRecordId) {
    log(
      "Found discrepancy: raw metadata client record id: ${rawData["clientRecordId"]} - obj metadata client record id ${metadata.clientRecordId}",
    );
    return !isValid;
  }

  if (rawData["clientRecordVersion"] != null &&
      rawData["clientRecordVersion"] != metadata.clientRecordVersion) {
    log(
      "Found discrepancy: raw metadata client record version: ${rawData["clientRecordVersion"]} - obj metadata client record version ${metadata.clientRecordVersion}",
    );
    return !isValid;
  }

  if (rawData["device"] != null && rawData["device"] != metadata.device) {
    log(
      "Found discrepancy: raw metadata device: ${rawData["device"]} - obj metadata device ${metadata.device}",
    );
    return !isValid;
  }

  return isValid;
}
